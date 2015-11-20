require 'spec_helper'

describe :Associations do

  describe :has_one do

    context('User, PhoneNumber' ) do

      let(:user) do
        create(:user)
      end

      let(:phone_number) do
        create(:phone_number, user: user)
      end

      context :restore do

        it 'should restore, user and phone_number bond to that' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          # In case of bury
          expect(user.bury).to be true
          expect(User.where_buried.count).to eql 1
          expect(PhoneNumber.where_buried.count).to eql 1
          expect(user.buried?).to be true

          # In case case restore
          expect(user.restore).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0
          expect(user.buried?).to be false

        end

        it 'should restore, phone_number without touching user' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          # In case of bury
          expect_any_instance_of(User).to_not receive(:bury!)
          expect(phone_number.bury).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 1

          # In case of restore
          expect_any_instance_of(User).to_not receive(:restore!)
          expect(phone_number.restore).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

        end

        context :on_failure do

          it 'should not restore user or phone_number ( in case of invalid user )' do

            user
            phone_number


            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            # Phone number should be restored first because of #before_restore callback on user object
            expect_any_instance_of(PhoneNumber).to receive(:restore!).once

            expect(user.restore).to be false
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore user or phone_number ( in case of invalid phone_number )' do

            user
            phone_number

            # In case of bury
            expect(user.bury).to be true

            # In case of restore
            raise_error = allow_instance_of(PhoneNumber).with_id(phone_number.id).raise(ActiveRecord::ActiveRecordError)

            expect(user.restore).to be false
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            raise_error.redo!

          end

        end
      end

      context :restore! do

        it 'should restore, user and phone_number bond to that' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          # In case of bury
          expect(user.bury!).to be true
          expect(User.where_buried.count).to eql 1
          expect(PhoneNumber.where_buried.count).to eql 1
          expect(user.buried?).to be true

          # In case case restore
          expect(user.restore!).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0
          expect(user.buried?).to be false

        end

        it 'should restore, phone_number without touching user' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          # In case of bury
          expect_any_instance_of(User).to_not receive(:bury!)
          expect(phone_number.bury!).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 1

          # In case of restore
          expect_any_instance_of(User).to_not receive(:restore!)
          expect(phone_number.restore!).to be true
          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

        end

        context :on_failure do

          it 'should not restore user or phone_number ( in case of invalid user )' do

            user
            phone_number


            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            # Phone number should be restored first because of #before_restore callback on user object
            expect_any_instance_of(PhoneNumber).to receive(:restore!).once

            expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore user or phone_number ( in case of invalid phone_number )' do

            user
            phone_number

            # In case of bury
            expect(user.bury!).to be true

            # In case of restore
            raise_error = allow_instance_of(PhoneNumber).with_id(phone_number.id).raise(ActiveRecord::ActiveRecordError)

            expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
            expect(User.where_buried.count).to eql 1
            expect(PhoneNumber.where_buried.count).to eql 1

            raise_error.redo!

          end

        end
      end

    end
  end
end
