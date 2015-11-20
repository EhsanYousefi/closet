require 'spec_helper'

describe :Associations do

  describe :has_many do

    describe 'dependent: :delete_all' do

      context('User, Issue, Patch') do

        let(:user) do
          create(:user)
        end

        let(:issues) do
          create_list(:issue, 3, user_id: user.id)
        end

        let(:patches) do
          issues.each do |issue|
            create_list(:patch, 3, issue: issue)
          end

          Patch.all
        end

        context :bury do

          it 'should bury user, and all issues bond to that' do

            issues

            expect(Issue.where_not_buried.count).to eql 3
            expect(user.buried?).to be false

            expect(user.bury).to be true

            expect(Issue.where_buried.count).to eql 3
            expect(user.buried?).to be true

          end

          it 'should bury user, and all issues bond to that, without touching any Patch' do

            issues
            patches

            expect(Issue.where_not_buried.count).to eql 3
            expect(Patch.where_not_buried.count).to eql 9
            expect(user.buried?).to be false

            expect_any_instance_of(Patch).to_not receive(:bury!)

            expect(user.bury).to be true

            expect(Issue.where_buried.count).to eql 3
            expect(Patch.where_buried.count).to eql 0

            expect(user.buried?).to be true

          end

          it 'should bury issue, and all patches bond to that' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect(issues.first.bury).to be true

            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 1
            expect(Patch.where_buried.count).to eql 3

          end

          it 'should bury patch without touching any issue or user' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect_any_instance_of(Issue).to_not receive(:bury!)
            expect_any_instance_of(User).to_not receive(:bury!)

            expect(patches.first.bury).to be true

            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 1

          end

          context :on_failure do

            it 'should not bury user and all issues bond to that if something went wrong in user' do

              issues
              patches

              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect(user.bury).to be false

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury user and all issues bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect(user.bury).to be false

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury issue and patches bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect(issue.bury).to be false


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury issue and patches bond to that if something went wrong in one of the patches' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Patch).with_id(issue.patches.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect(issue.bury).to be false


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury patch if something went wrong in that' do

              issues
              patches

              patch = patches.first(5).last
              raise_error = allow_instance_of(Patch).with_id(patch.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect(patch.bury).to be false


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end
        end
        context :bury! do

          it 'should bury user, and all issues bond to that' do

            issues

            expect(Issue.where_not_buried.count).to eql 3
            expect(user.buried?).to be false

            expect(user.bury!).to be true

            expect(Issue.where_buried.count).to eql 3
            expect(user.buried?).to be true

          end

          it 'should bury user, and all issues bond to that, without touching any Patch' do

            issues
            patches

            expect(Issue.where_not_buried.count).to eql 3
            expect(Patch.where_not_buried.count).to eql 9
            expect(user.buried?).to be false

            expect_any_instance_of(Patch).to_not receive(:bury!)

            expect(user.bury!).to be true

            expect(Issue.where_buried.count).to eql 3
            expect(Patch.where_buried.count).to eql 0

            expect(user.buried?).to be true

          end

          it 'should bury issue, and all patches bond to that' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect(issues.first.bury!).to be true

            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 1
            expect(Patch.where_buried.count).to eql 3

          end

          it 'should bury patch without touching any issue or user' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect_any_instance_of(Issue).to_not receive(:bury!)
            expect_any_instance_of(User).to_not receive(:bury!)

            expect(patches.first.bury!).to be true

            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 1

          end

          context :on_failure do

            it 'should not bury user and all issues bond to that if something went wrong in user' do

              issues
              patches

              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury user and all issues bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury issue and patches bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect{issue.bury!}.to raise_error(ActiveRecord::ActiveRecordError)


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury issue and patches bond to that if something went wrong in one of the patches' do

              issues
              patches

              issue = issues.first(2).last
              raise_error = allow_instance_of(Patch).with_id(issue.patches.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect{issue.bury!}.to raise_error(ActiveRecord::ActiveRecordError)


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not bury patch if something went wrong in that' do

              issues
              patches

              patch = patches.first(5).last
              raise_error = allow_instance_of(Patch).with_id(patch.id).raise(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              expect{patch.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end
        end

      end
    end
  end
end
