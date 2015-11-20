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

      context :bury do

        it 'should bury, user and phone_number bond to that' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          expect(user.bury).to be true

          expect(User.where_buried.count).to eql 1
          expect(PhoneNumber.where_buried.count).to eql 1
          expect(user.buried?).to be true

        end

        it 'should bury, phone_number without touching user' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          expect_any_instance_of(User).to_not receive(:bury!)

          expect(phone_number.bury).to be true

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 1

        end

        context :on_failure do

          it 'should not bury user or phone_number ( in case of invalid user )' do

            user
            phone_number

            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            # Phone number should be buried first because of #before_bury callback on user object
            expect_any_instance_of(PhoneNumber).to receive(:bury!)

            expect(user.bury).to be false

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury user or phone_number ( in case of invalid phone_number )' do

            user
            phone_number

            raise_error = allow_instance_of(PhoneNumber).with_id(phone_number.id).raise(ActiveRecord::ActiveRecordError)


            expect(user.bury).to be false

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            raise_error.redo!

          end

        end
      end

      context :bury! do

        it 'should bury, user and phone_number bond to that' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          expect(user.bury!).to be true

          expect(User.where_buried.count).to eql 1
          expect(PhoneNumber.where_buried.count).to eql 1
          expect(user.buried?).to be true

        end

        it 'should bury, phone_number without touching user' do

          user
          phone_number

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 0

          expect_any_instance_of(User).to_not receive(:bury!)

          expect(phone_number.bury!).to be true

          expect(User.where_buried.count).to eql 0
          expect(PhoneNumber.where_buried.count).to eql 1

        end

        context :on_failure do

          it 'should not bury user or phone_number ( in case of invalid user )' do

            user
            phone_number

            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            # Phone number should be buried first because of #before_bury callback on user object
            expect_any_instance_of(PhoneNumber).to receive(:bury!)

            expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury user or phone_number ( in case of invalid phone_number )' do

            user
            phone_number

            raise_error = allow_instance_of(PhoneNumber).with_id(phone_number.id).raise(ActiveRecord::ActiveRecordError)

            expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(User.where_buried.count).to eql 0
            expect(PhoneNumber.where_buried.count).to eql 0

            raise_error.redo!

          end

        end
      end

    end
  end
end
