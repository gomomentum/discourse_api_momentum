# require_relative 'log/ib/momentum_api/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby
    ownership_groups:       %w(Owner Owner_Manual),
    target_groups:          %w(trust_level_1),       # Mods GreatX BraveHearts trust_level_1
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    log_file:                File.expand_path('../logs/_run.log', __FILE__)
}

schedule_options = {
      group:{
          group_alias:                {
            # allowed_levels:         nil,
            # set_level:              nil,
            excludes:               %w()
        }
    },
}
discourse_options[:logger] = momentum_api_logger(discourse_options[:log_file])
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options)
discourse.apply_to_users
discourse.scan_summary
