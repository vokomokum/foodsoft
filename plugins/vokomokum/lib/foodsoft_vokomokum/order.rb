module FoodsoftVokomokum
  module Settle
    module Order
      extend ActiveSupport::Concern

      included do
        private

        def charge_group_orders!(user)
          charges = []
          note = transaction_note
          group_orders.joins(:ordergroup => :users).find_each do |group_order|
            user_id = FoodsoftVokomokum.userid_for_ordergroup(group_order.ordergroup)
            user_id.present? or raise Exception.new("No user for ordergroup '#{group_order.ordergroup.name}'")
            charges << {order_id: id, amount: group_order.price.to_f, user_id: user_id, note: note}
          end
          user.vokomokum_remote_msg = FoodsoftVokomokum.charge_members!(user.vokomokum_auth_cookies, charges)
          Rails.logger.info user.vokomokum_remote_msg
        end
      end
    end

    module Controller
      extend ActiveSupport::Concern

      included do
        rescue_from FoodsoftVokomokum::VokomokumException, with: :vokomokum_handle_exception

        after_action :vokomokum_show_msg_on_close, only: :close
      end

      private

      def vokomokum_handle_exception(e)
        redirect_to finance_order_index_url, alert: t('finance.balancing.close.alert', message: e.message)
      end

      def vokomokum_show_msg_on_close
        # replace flash with message from Vokomokum members system
        flash[:notice] = current_user.vokomokum_remote_msg
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  Order.send :include, FoodsoftVokomokum::Settle::Order
  Finance::BalancingController.send :include, FoodsoftVokomokum::Settle::Controller
end
