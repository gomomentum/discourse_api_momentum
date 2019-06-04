require_relative '../spec_helper'

describe MomentumApi::Discourse do

  let(:user_details) { {} }

  # let(:users) { fixture("user_list.json") }
  let(:users) { [
      {
          "id": 1,
          "username": "test_user",
          "uploaded_avatar_id": 7,
          "avatar_template": "/user_avatar/localhost/test_user/{size}/7.png",
          "email": "batman@gotham.com",
          "active": true,
          "admin": true,
          "moderator": false,
          "last_seen_at": "2015-01-03T13:46:59.822Z",
      }.to_json,
      {
          "id": 18,
          "username": "steve3",
          "uploaded_avatar_id": nil,
          "avatar_template": "/letter_avatar/steve3/{size}/2.png",
          "active": true,
          "admin": false,
          "moderator": false,
          "last_seen_at": "2015-01-02T15:49:34.257Z",
          "last_emailed_at": "2015-01-02T15:50:29.329Z",
      }.to_json] }

  let(:admin_client) do
    admin_client = instance_double('admin_client')
    expect(admin_client).to receive(:group_members).and_return(users)
    expect(admin_client).to receive(:user).and_return(user_details)
    admin_client
  end

  scan_options = {
      team_category_watching:   true,
      essential_watching:       true,
      growth_first_post:        true,
      meta_first_post:          true,
      trust_level_updates:      true,
      score_user_levels: {
          update_type:  'not_voted',      # have_voted, not_voted, newly_voted, all
          target_post:  28707,            # 28649
          target_polls: %w(version_two),  # basic new version_two
          poll_url:     'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
      },
      user_group_alias_notify:  true
  }

  do_live_updates =   false
  target_username =   nil
  target_groups   =   %w(trust_level_1) # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

  subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                          target_groups=target_groups, target_username=target_username, admin_client: admin_client) }
    # before :each do
    #   @discourse = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
    #                                           target_groups=target_groups, target_username=target_username, admin_client=admin_client)
    # end
    # connect_to_instance = double("connect_to_instance")

  # subject { @discourse }

  it ".apply_to_users" do
    subject.apply_to_users(scan_options)
    expect(subject).to respond_to(:apply_to_users)
    # expect(subject).to respond_to(:group_members)
  end

  # it ".apply_to_users" do
  #   subject.apply_to_users(scan_options)
  #   expect(subject).to respond_to(:apply_to_group_users)
  # end



  describe "#set_category_notification" do
 
    # before :each do
    #     @discourse = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
    #                                             target_groups=target_groups, target_username=target_username, admin_client=admin_client)
    #   end
    #   # connect_to_instance = double("connect_to_instance")
    # end
    #
    # subject { @discourse }
    #
    # it "#connect_to_instance" do
    #   expect(subject).to respond_to(:connect_to_instance)
    # end

    # it "#.apply_to_users" do
    #   expect(@discourse).to respond_to(:apply_to_users)
    # end
    #
    # it "#.apply_to_group_users" do
    #   expect(@discourse).to respond_to(:apply_to_group_users)
    # end

  end

  # describe "#user-badges" do
  #   before do
  #     stub_get("http://localhost:3000/user-badges/test_user.json").to_return(body: fixture("user_badges.json"), headers: { content_type: "application/json" })
  #   end
  #
  #   it "requests the correct resource" do
  #     subject.user_badges('test_user')
  #     expect(a_get("http://localhost:3000/user-badges/test_user.json")).to have_been_made
  #   end
  #
  #   it "returns the requested user badges" do
  #     badges = subject.user_badges('test_user')
  #     expect(badges).to be_an Array
  #     expect(badges.first).to be_a Hash
  #     expect(badges.first).to have_key('badge_type_id')
  #   end
  # end
end
