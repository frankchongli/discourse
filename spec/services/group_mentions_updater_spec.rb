require 'rails_helper'

RSpec.describe GroupMentionsUpdater do
  let(:post) { Fabricate(:post) }

  describe '.update' do
    it 'should update valid group mentions' do
      new_group_name = 'awesome_team'
      old_group_name = 'team'

      [
        ["@#{old_group_name} is awesome!", "@#{new_group_name} is awesome!"],
        ["This @#{old_group_name} is awesome!", "This @#{new_group_name} is awesome!"],
        ["Mention us @ @#{old_group_name}", "Mention us @ @#{new_group_name}"],
      ].each do |raw, expected_raw|
        group = Fabricate(:group, name: old_group_name)
        post.update!(raw: raw)
        group.update!(name: new_group_name)
        post.reload

        expect(post.raw_mentions).to eq([new_group_name])
        expect(post.raw).to eq(expected_raw)

        group.destroy!
      end
    end

    it 'should not update invalid group mentions' do
      group = Fabricate(:group, name: 'team')
      post.update!(raw: 'This is not valid@team.com')

      expect(post.reload.raw_mentions).to eq([])

      group.update!(name: 'new_team_name')

      expect(post.reload.raw_mentions).to eq([])
    end
  end
end
