require 'net/http'
require 'uri'

module FoodsoftVokomokum

  class VokomokumException < Exception; end
  class AuthnException < VokomokumException; end
  class InactiveException < AuthnException; end
  class UploadException < VokomokumException; end

  # Validate user at Vokomokum member system from existing cookies, return user info.
  #   When an unexpected condition occurs, raises FoodsoftVokomokum::AuthnException.
  #   When the user was not logged in, returns `nil`.
  def self.check_user(cookies)
    body = members_req('userinfo', cookies)
    Rails.logger.debug 'Vokomokum userinfo returned: ' + body
    json = ActiveSupport::JSON.decode(body)
    json['error'] and raise AuthnException.new('Vokomokum login failed: ' + json['error'])
    json['user_id'].blank? and return
    json['active'] or raise InactiveException.new("Welcome back! You can't order just yet, please contact membership@vokomokum.nl to become active again.")
    {
      id: json['user_id'],
      first_name: json['given_name'],
      last_name: [json['middle_name'], json['family_name']].compact.join(' '),
      email: json['email'],
      groups: json['groups']
    }
  rescue ActiveSupport::JSON.parse_error => error
    raise AuthnException.new('Vokomokum login returned an invalid response: ' + error.message)
  end

  # Charges members
  # @return [String] Status message on success
  def self.charge_members!(cookies, charges)
    json = members_req_json('charge-members', cookies, {charges: charges})
    json['msg']
  end

  # Sends payment reminders
  # @return [String] Status message on success
  def self.send_payment_reminders!(cookies)
    json = members_req_json('mail-payment-reminders', cookies)
    json['msg']
  end

  protected

  def self.base_url
    FoodsoftConfig[:vokomokum_members_api_url]
  end

  def self.auth_data
    {
      client_id: FoodsoftConfig[:vokomokum_client_id],
      client_secret: FoodsoftConfig[:vokomokum_client_secret]
    }
  end

  def self.members_req(path, cookies, data={})
    res = self.remote_req(self.base_url, path, cookies)
    Rails.logger.debug "Vokomokum #{path} returned: " + res.body
    res.body
  end

  def self.members_req_json(path, cookies, data=nil)
    if data
      res = self.remote_req(self.base_url, path, cookies) do |req|
        req.content_type = 'application/json'
        req.body = self.auth_data.merge(data).to_json
      end
    else
      res = self.remote_req(self.base_url, path, cookies)
    end
    Rails.logger.debug "Vokomokum #{path} returned: " + res.body
    json = ActiveSupport::JSON.decode(res.body)
    if json['status'] != 'ok'
      if json['msg'] =~ /only .* people can do this/i
        raise AuthnException.new('Vokomokum request failed: ' + json['msg'])
      else
        raise VokomokumException.new('Vokomokum request failed: ' + json['msg'])
      end
    else
      json
    end
  end

  def self.remote_req(url, path, cookies={})
    # include client id and secret
    path = "#{path}?#{self.auth_data.to_param}"
    # only keep relevant cookies
    cookies = cookies.select {|k,v| k=='Mem' || k=='Key'}
    uri = URI.join(url, path)
    if block_given?
      req = Net::HTTP::Post.new(uri.request_uri)
      yield req
    else
      req = Net::HTTP::Get.new(uri.request_uri)
    end
    # TODO cookie-encode the key and value
    req['Cookie'] = cookies.to_a.map {|v| "#{v[0]}=#{v[1]}"}.join('; ') #

    begin
      res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
    rescue Timeout::Error => exc
      raise UploadException.new("Timeout while connecting to Vokomokum: #{exc.message}")
    rescue Errno::ETIMEDOUT => exc
      raise UploadException.new("Timeout while connecting to Vokomokum: #{exc.message}")
    rescue Errno::ECONNREFUSED => exc
      raise UploadException.new("Could not connect to Vokomokum: #{exc.message}")
    rescue Exception => exc
      raise UploadException.new("Could not connect to Vokomokum: #{exc.message}")
    end

    res.code.to_i == 200 or raise UploadException.new("Vokomokum request returned with HTTP error #{res.code}")
    res
  end

end
