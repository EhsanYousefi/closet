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

        context :restore do

          it 'should restore user, and all issues bond to that' do

            issues

            expect(Issue.where_not_buried.count).to eql 3
            expect(user.buried?).to be false

            # In case of bury
            expect(user.bury).to be true
            expect(Issue.where_buried.count).to eql 3
            expect(user.buried?).to be true

            # In case of restore
            expect(user.restore).to be true
            expect(Issue.where_buried.count).to eql 0
            expect(user.buried?).to be false

          end

          it 'should restore user, and all issues bond to that, without touching any Patch' do

            issues
            patches

            expect(Issue.where_not_buried.count).to eql 3
            expect(Patch.where_not_buried.count).to eql 9
            expect(user.buried?).to be false

            expect_any_instance_of(Patch).to_not receive(:bury!)

            # In case of bury
            expect(user.bury).to be true
            expect(Issue.where_buried.count).to eql 3
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be true

            # In case of restore
            expect(user.restore).to be true
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

          end

          it 'should restore issue, and all patches bond to that' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            # In case of bury
            expect(issues.first.bury).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 1
            expect(Patch.where_buried.count).to eql 3

            # In case of restore
            expect(issues.first.restore).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0


          end

          it 'should restore patch without touching any issue or user' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect_any_instance_of(Issue).to_not receive(:bury!)
            expect_any_instance_of(User).to_not receive(:bury!)

            # In case of bury
            expect(patches.first.bury).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 1

            # In case of restore
            expect(patches.first.restore).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should not restore user and all issues bond to that if something went wrong in user' do

              issues
              patches


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(user.bury).to be true
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(user.restore).to be false
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should not restore user and all issues bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(user.bury).to be true
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(user.restore).to be false
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should not restore issue and patches bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(issue.bury).to be true
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect(issue.restore).to be false
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not restore issue and patches bond to that if something went wrong in one of the patches' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(issue.bury).to be true
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Patch).with_id(issue.patches.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect(issue.restore).to be false
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not restore patch if something went wrong in that' do

              issues
              patches

              patch = patches.first(5).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(patch.bury).to be true
              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 1
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Patch).with_id(patch.id).raise(ActiveRecord::ActiveRecordError)

              expect(patch.restore).to be false
              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 1
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end
        end

        context :restore! do

          it 'should restore user, and all issues bond to that' do

            issues

            expect(Issue.where_not_buried.count).to eql 3
            expect(user.buried?).to be false

            # In case of bury
            expect(user.bury!).to be true
            expect(Issue.where_buried.count).to eql 3
            expect(user.buried?).to be true

            # In case of restore
            expect(user.restore!).to be true
            expect(Issue.where_buried.count).to eql 0
            expect(user.buried?).to be false

          end

          it 'should restore user, and all issues bond to that, without touching any Patch' do

            issues
            patches

            expect(Issue.where_not_buried.count).to eql 3
            expect(Patch.where_not_buried.count).to eql 9
            expect(user.buried?).to be false

            expect_any_instance_of(Patch).to_not receive(:bury!)

            # In case of bury
            expect(user.bury!).to be true
            expect(Issue.where_buried.count).to eql 3
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be true

            # In case of restore
            expect(user.restore!).to be true
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

          end

          it 'should restore issue, and all patches bond to that' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            # In case of bury
            expect(issues.first.bury!).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 1
            expect(Patch.where_buried.count).to eql 3

            # In case of restore
            expect(issues.first.restore!).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0


          end

          it 'should restore patch without touching any issue or user' do

            issues
            patches

            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0
            expect(user.buried?).to be false

            expect_any_instance_of(Issue).to_not receive(:bury!)
            expect_any_instance_of(User).to_not receive(:bury!)

            # In case of bury
            expect(patches.first.bury!).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 1

            # In case of restore
            expect(patches.first.restore!).to be true
            expect(user.buried?).to be false
            expect(Issue.where_buried.count).to eql 0
            expect(Patch.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should not restore user and all issues bond to that if something went wrong in user' do

              issues
              patches


              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(user.bury!).to be true
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should not restore user and all issues bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(user.bury!).to be true
              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_not_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should not restore issue and patches bond to that if something went wrong in issue' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(issue.bury!).to be true
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Issue).with_id(issue.id).raise(ActiveRecord::ActiveRecordError)

              expect{issue.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not restore issue and patches bond to that if something went wrong in one of the patches' do

              issues
              patches

              issue = issues.first(2).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(issue.bury!).to be true
              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Patch).with_id(issue.patches.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect{issue.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 1
              expect(Patch.where_buried.count).to eql 3
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should not restore patch if something went wrong in that' do

              issues
              patches

              patch = patches.first(5).last

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 0
              expect(user.buried?).to be false

              # In case of bury
              expect(patch.bury!).to be true
              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 1
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Patch).with_id(patch.id).raise(ActiveRecord::ActiveRecordError)

              expect{patch.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Issue.where_buried.count).to eql 0
              expect(Patch.where_buried.count).to eql 1
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end
        end

      end
    end
  end
end
