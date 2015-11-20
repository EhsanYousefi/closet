require 'spec_helper'

describe :Persistence do

  let(:user) do
    create(:user)
  end

  let(:users) do
    create_list(:user, 10, email: 'ehsan.yousefi@live.com')
    User.where(email: 'ehsan.yousefi@live.com')
  end

  let(:users_2) do
    create_list(:user, 10)
    User.where.not(email: 'ehsan.yousefi@live.com')
  end


  describe 'Instance Methods' do

    describe 'bury' do

      context 'dependent: false' do

        it 'should bury user without call callbacks' do
          expect_any_instance_of(User).to_not receive(:run_callbacks)
          expect(user.bury( dependent: false )).to be true
        end

        it 'should bury! user without call callbacks' do
          expect_any_instance_of(User).to_not receive(:run_callbacks)
          expect(user.bury!( dependent: false )).to be true
        end

        it 'should not raise error if something went wrong during bury user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect(user.bury( dependent: false )).to be false
          raise_error.redo!
        end

        it 'should aise error if something went wrong during bury user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect{user.bury!( dependent: false )}.to raise_error(ActiveRecord::ActiveRecordError)
          raise_error.redo!
        end

      end

      context 'dependent: true' do

        it 'should bury user within call callbacks' do
          expect_any_instance_of(User).to receive(:run_callbacks)
          user.bury
        end

        it 'should bury! user within call callbacks' do
          expect_any_instance_of(User).to receive(:run_callbacks)
          user.bury!
        end

        it 'should not raise error if something went wrong during bury user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect(user.bury).to be false
          raise_error.redo!
        end

        it 'should raise error if something went wrong during bury! user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)
          raise_error.redo!
        end

      end

    end

    describe 'restore' do

      context 'dependent: false' do

        it 'should restore user without call callbacks' do
          expect_any_instance_of(User).to_not receive(:run_callbacks)
          expect(user.restore( dependent: false )).to be true
        end

        it 'should restore! user without call callbacks' do
          expect_any_instance_of(User).to_not receive(:run_callbacks)
          expect(user.restore!( dependent: false )).to be true
        end

        it 'should not raise error if something went wrong during restore user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect(user.restore( dependent: false )).to be false
          raise_error.redo!
        end

        it 'should raise error if something went wrong during restore! user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect{user.restore!( dependent: false )}.to raise_error(ActiveRecord::ActiveRecordError)
          raise_error.redo!
        end

      end

      context 'dependent: true' do

        it 'should restore user within call callbacks' do
          expect_any_instance_of(User).to receive(:run_callbacks)
          user.restore
        end

        it 'should restore! user within call callbacks' do
          expect_any_instance_of(User).to receive(:run_callbacks)
          user.restore!
        end

        it 'should not raise error if something went wrong during restore user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect(user.restore).to be false
          raise_error.redo!
        end

        it 'should aise error if something went wrong during restore user' do
          raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
          expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
          raise_error.redo!
        end

      end

    end


  end

  describe 'Class Methods' do

    describe 'where_buried' do
      it 'should return buried_users' do
        users.bury_all
        users_2

        expect(User.all.count).to eql 20
        expect(User.where_buried.count).to eql 10
      end
    end

    describe 'where_not_buried' do
      it 'should return buried_users' do
        users.bury_all
        users_2
        
        expect(User.all.count).to eql 20
        expect(User.where_not_buried.count).to eql 10
      end
    end

    describe 'bury_all' do

      context 'dependent: false' do

        it 'should bury_all users without call callbacks on each object' do
          users
          expect_any_instance_of(User).to_not receive(:run_callbacks)

          users.bury_all( dependent: false ).each do |user|
            expect(user.buried?).to be true
          end
        end

        it 'should bury_all! users without call callbacks on each object' do
          users
          expect_any_instance_of(User).to_not receive(:run_callbacks)

          users.bury_all!( dependent: false ).each do |user|
            expect(user.buried?).to be true
          end
        end

        it 'should not raise error if something went wrong during bury_all users' do
          raise_error = allow_instance_of(User).with_id(users.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect(users.bury_all( dependent: false )).to be false

          users.each do |u|
            expect(u.buried?).to be false
          end

          raise_error.redo!
        end

        it 'should raise error if something went wrong during bury_all! users' do
          raise_error = allow_instance_of(User).with_id(users.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect{users.bury_all!( dependent: false )}.to raise_error(ActiveRecord::ActiveRecordError)

          users.each do |user|
            expect(user.buried?).to be false
          end

          raise_error.redo!
        end

      end

      context 'dependent: true' do

        it 'should bury_all users within call callbacks' do
          users
          users_2
          users.bury_all

          users.each do |user|
            expect(user.buried?).to be true
          end

          users_2.each do |user|
            expect(user.buried?).to be false
          end
        end

        it 'should bury_all! users within call callbacks' do
          users
          users_2.bury_all!

          users.each do |user|
            expect(user.buried?).to be false
          end

          users_2.each do |user|
            expect(user.buried?).to be true
          end
        end

        it 'should not raise error if something went wrong during bury_all users' do
          raise_error = allow_instance_of(User).with_id(users_2.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect(users_2.bury_all).to be false
          expect(users.bury_all.class).to be Array

          users.each do |user|
            expect(user.buried?).to be true
          end

          users_2.each do |user|
            expect(user.buried?).to be false
          end

          raise_error.redo!
        end

        it 'should raise error if something went wrong during bury_all! users' do
          raise_error = allow_instance_of(User).with_id(users.first(3).last.id).raise(ActiveRecord::ActiveRecordError)
          expect{users.bury_all!}.to raise_error(ActiveRecord::ActiveRecordError)
          expect(users_2.bury_all!.class).to be Array

          users.each do |user|
            expect(user.buried?).to be false
          end

          users_2.each do |user|
            expect(user.buried?).to be true
          end

          raise_error.redo!
        end

      end

    end

    describe 'restore_all' do

      context 'dependent: false' do

        it 'should restore_all users without call callbacks on each object' do
          users
          expect_any_instance_of(User).to_not receive(:run_callbacks)

          users.restore_all( dependent: false ).each do |user|
            expect(user.buried?).to be false
          end
        end

        it 'should restore_all! users without call callbacks on each object' do
          users
          expect_any_instance_of(User).to_not receive(:run_callbacks)

          users.restore_all!( dependent: false ).each do |user|
            expect(user.buried?).to be false
          end
        end

        it 'should not raise error if something went wrong during restore_all users' do
          users.bury_all( dependent: false )

          users.each do |u|
            expect(u.buried?).to be true
          end

          raise_error = allow_instance_of(User).with_id(users.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect(users.restore_all( dependent: false )).to be false

          users.each do |u|
            expect(u.buried?).to be true
          end

          raise_error.redo!
        end

        it 'should raise error if something went wrong during restore_all! users' do

          users.bury_all( dependent: false )

          users.each do |u|
            expect(u.buried?).to be true
          end

          raise_error = allow_instance_of(User).with_id(users.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect{users.restore_all!( dependent: false )}.to raise_error(ActiveRecord::ActiveRecordError)

          users.each do |user|
            expect(user.buried?).to be true
          end

          raise_error.redo!
        end

      end

      context 'dependent: true' do

        it 'should restore_all users within call callbacks' do
          users
          users_2
          users.bury_all

          users.each do |user|
            expect(user.buried?).to be true
          end

          users.restore_all

          users.each do |user|
            expect(user.buried?).to be false
          end

          users_2.each do |user|
            expect(user.buried?).to be false
          end
        end

        it 'should restore_all! users within call callbacks' do
          users
          users_2.bury_all!

          users_2.each do |user|
            expect(user.buried?).to be true
          end

          users_2.restore_all!

          users_2.each do |user|
            expect(user.buried?).to be false
          end
        end

        it 'should not raise error if something went wrong during restore_all users' do
          expect(users_2.bury_all.class).to be Array

          users_2.each do |user|
            expect(user.buried?).to be true
          end

          raise_error = allow_instance_of(User).with_id(users_2.first(2).last.id).raise(ActiveRecord::ActiveRecordError)
          expect(users_2.bury_all).to be false

          users.each do |user|
            expect(user.buried?).to be false
          end

          users_2.each do |user|
            expect(user.buried?).to be true
          end

          raise_error.redo!
        end

        it 'should raise error if something went wrong during restore_all! users' do
          expect(users.bury_all.class).to be Array

          users.each do |user|
            expect(user.buried?).to be true
          end

          raise_error = allow_instance_of(User).with_id(users.first(3).last.id).raise(ActiveRecord::ActiveRecordError)
          expect{users.restore_all!}.to raise_error(ActiveRecord::ActiveRecordError)

          users.each do |user|
            expect(user.buried?).to be true
          end

          users_2.each do |user|
            expect(user.buried?).to be false
          end

          raise_error.redo!
        end

      end

    end

  end

end
