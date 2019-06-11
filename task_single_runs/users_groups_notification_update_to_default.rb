require '../lib/momentum_api'

def schedule_options
  {
      user_group_alias_notify:  true
  }
end

def discourse_options
  {
      do_live_updates:          false,
      target_username:          'Tim_Tannatt',
      target_groups:            %w(trust_level_1),
      instance:                 'live',
      api_username:             'KM_Admin'
  }
end

master_client = MomentumApi::Discourse.new(discourse_options, schedule_options)

scan_options = {
    user_group_alias_notify:  true
}

master_client.apply_to_users(scan_options)

master_client.scan_summary
