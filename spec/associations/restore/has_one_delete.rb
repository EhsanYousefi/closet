require 'spec_helper'

describe :Associations do

  describe :has_one do

    context('User, Address, Coordinate' ) do

      let(:user) do
        create(:user)
      end

      let(:address) do
        create(:address, user: user)
      end

      let(:coordinate) do
        create(:coordinate, address: address)
      end

      context :restore do

        it 'should restore user and address without touching coordinate' do

          address
          coordinate

          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0
          expect_any_instance_of(Coordinate).to_not receive(:bury!)

          # In case of bury
          expect(user.bury).to be true
          expect(Address.where_buried.count).to eql 1
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 1

          # In case of restore
          expect(user.restore).to be true
          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0

        end

        it 'should restore address and coordinate bond to that without touching user' do

          address
          coordinate

          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0
          expect_any_instance_of(User).to_not receive(:bury!)

          # In case of bury
          expect(address.bury).to be true
          expect(Address.where_buried.count).to eql 1
          expect(Coordinate.where_buried.count).to eql 1
          expect(User.where_buried.count).to eql 0

          # In case of restore
          expect(address.restore).to be true
          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0

        end

        it 'should restore user even if any address not assigned to that' do

          expect(User.where_buried.count).to eql 0
          # In case of bury
          expect(user.bury).to be true
          expect(user.buried?).to be true
          # In case of restore
          expect(user.restore).to be true
          expect(user.buried?).to be false

        end

        context :on_failure do

          it 'should not restore user if something went wrong in address' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(Address).with_id(address.id).raise(ActiveRecord::ActiveRecordError)

            expect_any_instance_of(Coordinate).to_not receive(:bury!)

            expect(user.restore).to be false

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore user and address bond to that if something went wrong in user' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            # In case restore
            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Coordinate).to_not receive(:bury!)

            expect(user.restore).to be false
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore address if something went wrong in coordinate' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(address.bury).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Coordinate).with_id(address.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(User).to_not receive(:restore!)

            expect(address.restore).to be false
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not restore address and coordinate bond to that if something went wrong in address' do

            address
            coordinate


            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(address.bury).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Address).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(User).to_not receive(:bury!)

            expect(address.bury).to be false

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            raise_error.redo!

          end

        end
      end

      context :restore! do

        it 'should restore user and address without touching coordinate' do

          address
          coordinate

          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0
          expect_any_instance_of(Coordinate).to_not receive(:bury!)

          # In case of bury
          expect(user.bury!).to be true
          expect(Address.where_buried.count).to eql 1
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 1

          # In case of restore
          expect(user.restore!).to be true
          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0

        end

        it 'should restore address and coordinate bond to that without touching user' do

          address
          coordinate

          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0
          expect_any_instance_of(User).to_not receive(:bury!)

          # In case of bury
          expect(address.bury!).to be true
          expect(Address.where_buried.count).to eql 1
          expect(Coordinate.where_buried.count).to eql 1
          expect(User.where_buried.count).to eql 0

          # In case of restore
          expect(address.restore!).to be true
          expect(Address.where_buried.count).to eql 0
          expect(Coordinate.where_buried.count).to eql 0
          expect(User.where_buried.count).to eql 0

        end

        it 'should restore user even if any address not assigned to that' do

          expect(User.where_buried.count).to eql 0
          # In case of bury
          expect(user.bury!).to be true
          expect(user.buried?).to be true
          # In case of restore
          expect(user.restore!).to be true
          expect(user.buried?).to be false

        end

        context :on_failure do

          it 'should not restore user if something went wrong in address' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(Address).with_id(address.id).raise(ActiveRecord::ActiveRecordError)

            expect_any_instance_of(Coordinate).to_not receive(:bury!)

            expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore user and address bond to that if something went wrong in user' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            # In case restore
            raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Coordinate).to_not receive(:bury!)

            expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore address if something went wrong in coordinate' do

            address
            coordinate

            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(address.bury!).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Coordinate).with_id(address.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(User).to_not receive(:restore!)

            expect{address.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not restore address and coordinate bond to that if something went wrong in address' do

            address
            coordinate


            expect(Address.where_buried.count).to eql 0
            expect(Coordinate.where_buried.count).to eql 0
            expect(User.where_buried.count).to eql 0

            # In case of bury
            expect(address.bury!).to be true
            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Address).with_id(user.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(User).to_not receive(:bury!)

            expect{address.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Address.where_buried.count).to eql 1
            expect(Coordinate.where_buried.count).to eql 1
            expect(User.where_buried.count).to eql 0

            raise_error.redo!

          end

        end
      end

    end

  end

end
