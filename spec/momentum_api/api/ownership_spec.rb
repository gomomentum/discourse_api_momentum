require_relative '../../spec_helper'

describe MomentumApi::Ownership do
  
  let(:subscription_expires_2020_08_25) { json_fixture("subscription_expires_2020_08_25.json") }
  let(:subscription_expires_2021_08_23) { json_fixture("subscription_expires_2021_08_23.json") }
  let(:user_details_ownership_blank) { json_fixture("user_details_ownership_blank.json") }
  let(:user_details_ownership_blank_moderator) { json_fixture("user_details_ownership_blank_moderator.json") }
  let(:user_details_ownership_blank_group_removed) { json_fixture("user_details_ownership_blank_group_removed.json") }

  let(:user_details_ownership_2020_08_25_CA_R0) { json_fixture("user_details_ownership_2020_08_25_CA_R0.json") }
  let(:user_details_ownership_2020_08_25_CA_R1) { json_fixture("user_details_ownership_2020_08_25_CA_R1.json") }
  let(:user_details_ownership_2020_08_25_CA_R2) { json_fixture("user_details_ownership_2020_08_25_CA_R2.json") }
  let(:user_details_ownership_2020_08_25_CA_R3) { json_fixture("user_details_ownership_2020_08_25_CA_R3.json") }
  let(:user_details_ownership_2021_08_23_CA_R0) { json_fixture("user_details_ownership_2021_08_23_CA_R0.json") }

  let(:user_details_ownership_2021_10_02_ZM) { json_fixture("user_details_ownership_2021_10_02_ZM.json") }
  let(:user_details_ownership_2021_10_02_ZM_R0) { json_fixture("user_details_ownership_2021_10_02_ZM_R0.json") }
  let(:user_details_ownership_2020_01_02_NU_R0) { json_fixture("user_details_ownership_2020_01_02_NU_R0.json") }
  let(:user_details_ownership_2020_01_02_NU_R1) { json_fixture("user_details_ownership_2020_01_02_NU_R1.json") }
  let(:user_details_ownership_2020_01_02_NU_R2) { json_fixture("user_details_ownership_2020_01_02_NU_R2.json") }
  let(:user_details_ownership_2020_01_02_NU_R3_group_removed) { json_fixture("user_details_ownership_2020_01_02_NU_R3_group_removed.json") }

  let(:user_details_ownership_renews_value_invalid) { json_fixture("user_details_ownership_renews_value_invalid.json") }
  let(:user_details_ownership_renews_value_08_23_2020_CA_R0) { json_fixture("user_details_ownership_renews_value_08_23_2021_CA_R0.json") }

  ownership_tasks = schedule_options[:ownership]
  targets_user_detail_calls = 27
  date_today_calls = 12
  options_calls = 4

  let(:mock_user_client) do
    mock_user_client = instance_double('user_client')
    expect(mock_user_client).to receive(:get_subscriptions).once.and_return []
    mock_user_client
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).once.and_return discourse_options
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return mock_discourse
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:user_details).exactly(26).times.and_return user_details_ownership_2020_01_02_NU_R0
    expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
    mock_man
  end

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    mock_dependencies
  end

  describe '.run' do

    let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_tasks, mock: mock_dependencies) }


    context 'Ownership actions against a valid YYYY-mm-dd, non-expiring user renews_value' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2019,12,3)
        mock_dependencies
      end

      it "inits and finds 2 Ownership actions and a valid user renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
      end

    end
    

    context 'Ownership actions against a invalid mm-dd-YYYY, expiring user renews_value' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return user_details_ownership_renews_value_08_23_2020_CA_R0
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return Date.new(2020,8,18)
        mock_dependencies
      end

      it "inits and finds 2 Ownership actions and a valid user renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end


    context 'invalid user renews_value' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return user_details_ownership_renews_value_invalid
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return discourse_options
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_today) do
        mock_today = instance_double('today')
        expect(mock_today).to receive(:strftime).exactly(1).times.and_return '2020-01-02'
        mock_today
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return mock_today
        mock_dependencies
      end

      it "inits and finds Ownership actions and an invalid renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end


    context 'invalid user renews_value, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:new_user_found][:do_task_update] = true
      
      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(34).times.and_return user_details_ownership_renews_value_invalid
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:group_add).exactly(1).times
                                                        .with(108, {username: 'Tony_Christopher'})
                                                        .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:update_user).exactly(1).times
                                                          .with("Tony_Christopher", {user_fields: {'6': '2020-01-02 NU R0'}})
                                                          .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:user).twice
                                                   .and_return user_details_ownership_2021_10_02_ZM_R0
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(8).times.and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        expect(mock_discourse).to receive(:admin_client).exactly(4).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(13).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_today) do
        mock_today = instance_double('today')
        expect(mock_today).to receive(:strftime).exactly(1).times.and_return '2020-01-02'
        mock_today
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return mock_today
        expect(mock_dependencies).to receive(:send_private_message)
                                       .with(mock_man, /Thank you for your interest in Momentum, Tony Christopher/,
                                             /Thank you for Your Interest in Momentum!/,
                                             from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it "inits and finds Ownership actions and an invalid renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end


    context 'Card Auto Renewing user expiring next week, update off' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return discourse_options
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return(user_details_ownership_2020_08_25_CA_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,8,20)
        mock_dependencies
      end

      it 'sends PM asking user to renew and sets user profile Renews value to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end

    
    context 'New User last week, update off' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return discourse_options
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return user_details_ownership_2020_01_02_NU_R0
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,1,10)
        mock_dependencies
      end

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end


    context 'New User last week, do_live_updates' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true
      
      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return user_details_ownership_2020_01_02_NU_R0
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end
      
      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,1,10)
        mock_dependencies
      end

      it 'finds user expiring in 1 week' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end

    
    context 'Card Auto Renewing user expires in 2 weeks, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expires_next_week][:do_task_update] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(1).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(26).times.and_return user_details_ownership_2020_08_25_CA_R0
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,8,14)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'checks user but does nothing' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(0)
      end

    end

    
    context 'Card Auto Renewing user expires next week, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expires_next_week][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2020-08-25 CA R1'}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:user).once
                                         .and_return user_details_ownership_2020_08_25_CA_R1
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(options_calls).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(7).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(29).times.and_return user_details_ownership_2020_08_25_CA_R0
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,8,20)
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Just a friendly reminder/, /Thank You for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: nil)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end


    context 'Card Auto Renewing user expired yesterday, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expired_yesterday][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2020-08-25 CA R2'}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:user).once
                                         .and_return user_details_ownership_2020_08_25_CA_R2
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(options_calls).and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(7).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(29).times.and_return user_details_ownership_2020_08_25_CA_R1
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,8,26)
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /The men don't want to see you go/, /Wait, Your Momentum Ownership Has Expired!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: nil)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end

    
    context 'Card Auto Renewing user expired a week ago final, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expired_last_week_final][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2020-08-25 CA R3'}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:group_add).once
                                         .with(107, {username: 'Tony_Christopher'})
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:user).twice
                                         .and_return user_details_ownership_2020_08_25_CA_R3
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(8).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(4).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(13).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(33).times.and_return user_details_ownership_2020_08_25_CA_R2
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,9,2)
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /We sent you a couple messages about your expired Momentum/,
                                               /Momentum Does Not Want to See You Go!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end
    end

    
    context 'Card Auto Renewing user expired 2 weeks ago, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expired_last_week_final][:do_task_update] = true
      
      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(1).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(26).times.and_return user_details_ownership_2020_08_25_CA_R3
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,9,9)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'checks user but does nothing' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(0)
      end
    end


    context 'New User 3 weeks ago, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:new_user_three_weeks_ago][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with('Tony_Christopher', {user_fields: {'6': '2020-01-02 NU R3'}})
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_2020_01_02_NU_R2
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(5).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(8).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(29).times
                                .and_return user_details_ownership_2020_01_02_NU_R2
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,1,24)
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Don't let Momentum get away/,
                                               /One Last Thought/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end

    
    context 'New User 2 weeks ago, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:new_user_two_weeks_ago][:do_task_update] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(1).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(26).times
                                .and_return user_details_ownership_2020_01_02_NU_R3_group_removed
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2020,1,17)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'checks user but does nothing' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(0)
      end

    end


    context 'Non-Owner, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_new_subscription_found][:do_task_update] = true
      ownership_do_task_update[:auto][:card_auto_renew_expires_next_week][:do_task_update] = true
      ownership_do_task_update[:auto][:card_auto_renew_expired_yesterday][:do_task_update] = true
      ownership_do_task_update[:auto][:card_auto_renew_expired_last_week_final][:do_task_update] = true
      ownership_do_task_update[:manual][:zelle_new_found][:do_task_update] = true
      ownership_do_task_update[:manual][:zelle_expires_next_week][:do_task_update] = true
      ownership_do_task_update[:manual][:zelle_expired_today][:do_task_update] = true
      ownership_do_task_update[:manual][:zelle_final][:do_task_update] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return []
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(targets_user_detail_calls).times.and_return user_details_ownership_blank_group_removed
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_today) do
        mock_today = instance_double('today')
        expect(mock_today).to receive(:strftime).exactly(1).times.and_return '2020-01-02'
        mock_today
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return mock_today
        mock_dependencies
      end


      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'checks user but does nothing' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(0)
      end

    end

    
    context 'Card Auto ownership new, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true
      
      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_new_subscription_found][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2020-08-25 CA R0'}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_2020_08_25_CA_R0
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(4).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(7).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(31).times.and_return user_details_ownership_blank
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Thank you for your ownership of Momentum, Tony Christopher/,
                                               /Thank you for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends new Owner admin PM and sets user to R0' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end

    
    context 'manual ownership new, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:zelle_new_found][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:group_add).once
                                         .with(45, {username: 'Tony_Christopher'})
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2021-10-02 ZM R0'}})
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:user).twice
                                         .and_return user_details_ownership_2021_10_02_ZM_R0
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(6).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        expect(mock_discourse).to receive(:admin_client).exactly(4).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(11).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(34).times
                                .and_return user_details_ownership_2021_10_02_ZM
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(date_today_calls).times.and_return Date.new(2019,10,03)
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Thank you for your ownership of Momentum, Tony Christopher/,
                                               /Thank you for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends new Owner admin PM and sets user to R0' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql 1
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql 1
        expect(ownership.instance_variable_get(:@counters)[:'Users Added to Group']).to eql 1
      end

    end


    context 'Card Auto Renewing auto-renews second year, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_new_subscription_found][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2021-08-23 CA R0'}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:user).once
                                         .and_return user_details_ownership_2021_08_23_CA_R0
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(4).and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(7).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_subscriptions).exactly(1).times.and_return subscription_expires_2021_08_23
        mock_user_client
      end
      
      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(25).times.and_return user_details_ownership_2020_08_25_CA_R1
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(8).times.and_return(Date.new(2020,8,23))
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Thank you for your ownership of Momentum, Tony Christopher/,
                                               /Thank you for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end


    context 'blank renews profile non-owner CHANGED Nov 2, 2019 moved from Owner_Manual group and moderation revoked' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:new_user_found][:do_task_update] = true

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(39).times.and_return user_details_ownership_blank_moderator
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {"6": "2020-01-02 NU R0"}})
                                         .and_return({"body": {"success": "OK"}})
        expect(mock_admin_client).to receive(:user).once
                                         .and_return user_details_ownership_2020_01_02_NU_R1
        expect(mock_admin_client).to receive(:user).exactly(2).times
                                         .and_return user_details_ownership_blank_group_removed
        expect(mock_admin_client).to receive(:group_add).once
                                         .with(108, {username: 'Tony_Christopher'})
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:group_remove).once
                                         .with(136, username: 'Tony_Christopher')
                                         .and_return({'body': {'success': 'OK'}})
        expect(mock_admin_client).to receive(:revoke_moderation).once.with(8)
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(11).times.and_return options_do_live_updates
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(7).times.and_return mock_admin_client
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(19).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_today) do
        mock_today = instance_double('today')
        expect(mock_today).to receive(:strftime).exactly(1).times.and_return '2020-01-02'
        mock_today
      end
      
      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return mock_today
        expect(mock_dependencies).to receive(:send_private_message)
                                       .with(mock_man, /Thank you for your interest in Momentum, Tony Christopher/,
                                             /Thank you for Your Interest in Momentum!/,
                                             from_username: 'Kim_Miller', to_username: nil, cc_username: 'KM_Admin')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'removes user from Owner_Manual group' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end
    end

    
    context '.run sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(28).times.and_return user_details_ownership_renews_value_invalid
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once
                                         .and_return user_details_ownership_renews_value_invalid
        expect(mock_admin_client).to receive(:group_remove).once
                                         .with(45, username: 'Tony_Christopher')
                                         .and_return({'body': {'success': 'OK'}})
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return discourse_options_issue_user
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return mock_discourse
        mock_schedule
      end

      let(:mock_today) do
        mock_today = instance_double('today')
        expect(mock_today).to receive(:strftime).exactly(1).times.and_return '2020-01-02'
        mock_today
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(1).times.and_return mock_today
        mock_dependencies
      end

      it 'sees issue user' do
        expect { ownership.run(mock_man) }
            .to output(/Tony_Christopher in Ownership/).to_stdout
      end
    end

  end
end

