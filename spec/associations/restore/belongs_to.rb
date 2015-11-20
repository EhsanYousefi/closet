require 'spec_helper'

describe :Associations do

  describe :belongs_to do

    context('Building, Floor, Column') do

      let(:building) do
        create(:building)
      end

      let(:floors) do
        create_list(:floor, 7, building: building)
      end

      let(:columns) do

        floors.each do |floor|
          create_list(:column, 7, floor: floor)
        end

        Column.all

      end

      context :restore do

        it 'should restore floor, and building bond to floor' do

          building
          floors
          columns

          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49

          # In case of bury
          expect(floors.first.bury).to be true
          expect(Building.where_not_buried.count).to eql 0
          expect(Floor.where_not_buried.count).to eql 6
          expect(Column.where_not_buried.count).to eql 49
          expect(floors.first.buried?).to eql true

          # In case of bury
          expect(floors.first.restore).to be true
          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49
          expect(floors.first.buried?).to eql false

        end

        it 'should restore column, and the floor bond to column, and building' do

          building
          floors
          columns

          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49

          # In case of bury
          expect(columns.first.bury).to be true
          expect(Building.where_not_buried.count).to eql 0
          expect(Floor.where_not_buried.count).to eql 6
          expect(Column.where_not_buried.count).to eql 48
          expect(columns.first.buried?).to eql true

          # In case of restore
          expect(columns.first.restore).to be true
          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49
          expect(columns.first.buried?).to eql false

        end

        context :on_failure do

          it 'should not restore invalid object(column), and should not call #restore method on parent( floor )' do

            building
            floors
            columns

            column = columns.first(5).last

            expect(Building.where_not_buried.count).to eql 1
            expect(Floor.where_not_buried.count).to eql 7
            expect(Column.where_not_buried.count).to eql 49

            # In case of bury
            expect(column.bury).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            # In case of restore
            raise_error = allow_instance_of(Column).with_id(column.id).raise(ActiveRecord::ActiveRecordError)
            # Should not receive :restore! because floor restored after column
            expect_any_instance_of(Floor).to_not receive(:restore!)

            expect(column.restore).to be false
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            raise_error.redo!

          end

          it 'should not rollback buried record(column), if something went wrong( in case of floor )' do

            # In general, column should not get bury(in case of invalid floor), we should fix this problem
            # TODO

            building
            floors
            columns

            floor = floors.first(5).last

            expect(Building.where_not_buried.count).to eql 1
            expect(Floor.where_not_buried.count).to eql 7
            expect(Column.where_not_buried.count).to eql 49

            # In case of bury
            # It should be true becuase we run belongs_to dependent callback # after_bury not # before_bury
            expect(floor.columns.first.bury).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            # In case of restore
            raise_error = allow_instance_of(Floor).with_id(floor.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Floor).to receive(:restore!)

            expect(floor.columns.first.restore).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 49

            raise_error.redo!

          end
        end
      end

      context :restore! do

        it 'should restore floor, and building bond to floor' do

          building
          floors
          columns

          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49

          # In case of bury
          expect(floors.first.bury!).to be true
          expect(Building.where_not_buried.count).to eql 0
          expect(Floor.where_not_buried.count).to eql 6
          expect(Column.where_not_buried.count).to eql 49
          expect(floors.first.buried?).to eql true

          # In case of bury
          expect(floors.first.restore!).to be true
          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49
          expect(floors.first.buried?).to eql false

        end

        it 'should restore column, and the floor bond to column, and building' do

          building
          floors
          columns

          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49

          # In case of bury
          expect(columns.first.bury!).to be true
          expect(Building.where_not_buried.count).to eql 0
          expect(Floor.where_not_buried.count).to eql 6
          expect(Column.where_not_buried.count).to eql 48
          expect(columns.first.buried?).to eql true

          # In case of restore
          expect(columns.first.restore!).to be true
          expect(Building.where_not_buried.count).to eql 1
          expect(Floor.where_not_buried.count).to eql 7
          expect(Column.where_not_buried.count).to eql 49
          expect(columns.first.buried?).to eql false

        end

        context :on_failure do

          it 'should not restore invalid object(column), and should not call #restore method on parent( floor )' do

            building
            floors
            columns

            column = columns.first(5).last

            expect(Building.where_not_buried.count).to eql 1
            expect(Floor.where_not_buried.count).to eql 7
            expect(Column.where_not_buried.count).to eql 49

            # In case of bury
            expect(column.bury!).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            # In case of restore
            raise_error = allow_instance_of(Column).with_id(column.id).raise(ActiveRecord::ActiveRecordError)
            # Should not receive :restore! because floor restored after column
            expect_any_instance_of(Floor).to_not receive(:restore!)

            expect{column.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            raise_error.redo!

          end

          it 'should not rollback buried record(column), if something went wrong( in case of floor )' do

            # In general, column should not get bury(in case of invalid floor), we should fix this problem
            # TODO

            building
            floors
            columns

            floor = floors.first(5).last

            expect(Building.where_not_buried.count).to eql 1
            expect(Floor.where_not_buried.count).to eql 7
            expect(Column.where_not_buried.count).to eql 49

            # In case of bury
            # It should be true becuase we run belongs_to dependent callback # after_bury not # before_bury
            expect(floor.columns.first.bury!).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 48

            # In case of restore
            raise_error = allow_instance_of(Floor).with_id(floor.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Floor).to receive(:restore!)

            expect(floor.columns.first.restore!).to be true
            expect(Building.where_not_buried.count).to eql 0
            expect(Floor.where_not_buried.count).to eql 6
            expect(Column.where_not_buried.count).to eql 49

            raise_error.redo!

          end

        end

      end


    end
  end
end
