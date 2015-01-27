ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      # span class: "blank_slate" do
      #   span I18n.t("active_admin.dashboard_welcome.welcome")
      #   small I18n.t("active_admin.dashboard_welcome.call_to_action")
      # end
    end

    columns do
      column do
        panel "Recent BTS Accounts" do
          ul do
            BtsAccount.order('id desc').limit(30).map do |a|
              li ("#{a.created_at.strftime("%F %H:%M")} " + link_to(a.name, admin_bts_account_path(a))).html_safe
            end
          end
        end

        panel "Top Referrers" do
          ul do
            BtsAccount.select([:referrer, 'count(*) as count']).where('referrer is not null').group(:referrer).order('count desc').map do |r|
              li "#{r.referrer}: #{r.count}"
            end
          end
        end
      end

      column do
        panel "Recent DVS Accounts" do
          ul do
            DvsAccount.order('id desc').limit(40).map do |a|
              li ("#{a.created_at.strftime("%F %H:%M")} " + link_to(a.name, admin_dvs_account_path(a))).html_safe
            end
          end
        end
      end

      column do
        panel "Recent User Actions" do
          ul do
            UserAction.order('id desc').limit(40).map do |a|
              li (link_to("#{a.created_at.strftime("%F %H:%M:%S")}",admin_user_action_path(a)) + " #{a.action}: #{a.value}").html_safe
            end
          end
        end
      end

    end

  end

end
