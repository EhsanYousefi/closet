require 'spec_helper'

describe :Validations do
  describe :uniqueness do

    let(:buried_users) do
      create_list(:user, 3, buried_at: Time.now)
      User.where_buried
    end

    let(:users) do
      create_list(:user, 3)
      User.where_not_buried
    end

    let(:buried_schools) do
      create_list(:school, 3, buried_at: Time.now)
      School.where_buried
    end

    let(:schools) do
      create_list(:school, 3)
      School.where_not_buried
    end

    let(:buried_buildings) do
      create_list(:building, 3, buried_at: Time.now)
      Building.where_buried
    end

    let(:buildings) do
      create_list(:building, 3)
      Building.where_not_buried
    end

    it 'should raise validation error in case of uniquness with conditions -> { where_not_buried }' do

        users
        buried_users

        user = users.first
        user.name = users.last.name
        expect{user.save!}.to raise_error(ActiveRecord::RecordInvalid)
        user.name = buried_users.first.name
        expect(user.save!).to be true

    end

    it 'should raise validation error in case of uniquness with conditions -> { where_buried }' do

        schools
        buried_schools

        school = buried_schools.first
        school.name = buried_schools.last.name
        expect{school.save!}.to raise_error(ActiveRecord::RecordInvalid)
        school.name = schools.first.name
        expect(school.save!).to be true

    end

    it 'should raise validation error in case of uniquness without any conditions' do

        buildings
        buried_buildings

        building = buried_buildings.first
        building.name = buried_buildings.last.name
        expect{building.save!}.to raise_error(ActiveRecord::RecordInvalid)
        building.name = buildings.first.name
        expect{building.save!}.to raise_error(ActiveRecord::RecordInvalid)


    end

  end
end
