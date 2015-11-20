require 'spec_helper'

describe :Associations do

  describe :belongs_to do

    context('School, Teacher, Student') do

      let(:school) do
        create(:school)
      end

      let(:school_2) do
        create(:school)
      end

      let(:teachers) do
        create_list(:teacher, 7, school: school)
      end

      let(:students) do

        teachers.each do |teacher|
          create_list(:student, 7, teacher: teacher)
        end

        Student.all

      end

      context :restore do

        it 'should restore school and all teachers, and do not touch any student' do

          school_2
          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

          # In case of bury
          expect(school.buried?).to be false
          expect(school.bury).to be true
          expect(school.buried?).to be true
          expect(Teacher.where_buried.count).to eql 7
          expect(School.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 0

          # In case of restore
          expect_any_instance_of(Student).to_not receive(:restore!)
          expect(school.buried?).to be true
          expect(school.restore).to be true
          expect(school.buried?).to be false
          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

        end

        it 'should restore school if one of the teachers get restored' do

          school_2
          teachers

          expect(Teacher.where_buried.count).to eql 0
          expect(school.buried?).to be false

          teacher = teachers.first(4).last

          # In case of bury
          expect(teacher.bury).to be true
          expect(school.buried?).to be true
          expect(teacher.buried?).to be true
          expect(Teacher.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 1

          # In case of restore
          expect(teacher.restore).to be true
          expect(school.buried?).to be false
          expect(teacher.buried?).to be false
          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

        end

        it 'should restore student, and teacher bond to that without restoring school' do

          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

          # In case of bury
          student = students.first(5).last
          expect(student.bury).to be true

          expect(Teacher.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be true

          # In case of restore
          expect_any_instance_of(User).to_not receive(:restore!)

          expect(student.restore).to be true

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be false


        end

        context :on_failure do

          it 'should not restore school when one of the teacheres get restored in case of invalid school' do

            teachers
            students

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            teacher = teachers.first(5).last

            # In case of bury
            expect(teacher.bury).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(School).with_id(school.id).raise(ActiveRecord::ActiveRecordError)

            expect(teacher.restore).to be false

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore school when one of the teacheres get restored in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(5).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            # In case of bury
            expect(teacher.bury).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect_any_instance_of(School).to_not receive(:restore!)

            expect(teacher.restore).to be false

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore teacher when one of students get restored, in case of invalid student' do

            teachers
            students

            student = students.first(18).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            # In case of bury
            expect(student.bury).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Student).with_id(student.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Teacher).to_not receive(:restore!)

            expect(student.restore).to be false

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not restore teacher when one of students get restored, in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(6).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(teacher.students.first.bury).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect(teacher.students.first.restore).to be false

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

        end

      end

      context :restore! do

        it 'should restore school and all teachers, and do not touch any student' do

          school_2
          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

          # In case of bury
          expect(school.buried?).to be false
          expect(school.bury!).to be true
          expect(school.buried?).to be true
          expect(Teacher.where_buried.count).to eql 7
          expect(School.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 0

          # In case of restore
          expect_any_instance_of(Student).to_not receive(:restore!)
          expect(school.buried?).to be true
          expect(school.restore!).to be true
          expect(school.buried?).to be false
          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

        end

        it 'should restore school if one of the teachers get restored' do

          school_2
          teachers

          expect(Teacher.where_buried.count).to eql 0
          expect(school.buried?).to be false

          teacher = teachers.first(4).last

          # In case of bury
          expect(teacher.bury!).to be true
          expect(school.buried?).to be true
          expect(teacher.buried?).to be true
          expect(Teacher.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 1

          # In case of restore
          expect(teacher.restore!).to be true
          expect(school.buried?).to be false
          expect(teacher.buried?).to be false
          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

        end

        it 'should restore student, and teacher bond to that without restoring school' do

          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

          # In case of bury
          student = students.first(5).last
          expect(student.bury!).to be true

          expect(Teacher.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be true

          # In case of restore
          expect_any_instance_of(User).to_not receive(:restore!)

          expect(student.restore!).to be true

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be false


        end

        context :on_failure do

          it 'should not restore school when one of the teacheres get restored in case of invalid school' do

            teachers
            students

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            teacher = teachers.first(5).last

            # In case of bury
            expect(teacher.bury!).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(School).with_id(school.id).raise(ActiveRecord::ActiveRecordError)

            expect{teacher.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore school when one of the teacheres get restored in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(5).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            # In case of bury
            expect(teacher.bury!).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            # In case of restore
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect_any_instance_of(School).to_not receive(:restore!)

            expect{teacher.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 1

            raise_error.redo!

          end

          it 'should not restore teacher when one of students get restored, in case of invalid student' do

            teachers
            students

            student = students.first(18).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            # In case of bury
            expect(student.bury!).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            # In case of restore
            raise_error = allow_instance_of(Student).with_id(student.id).raise(ActiveRecord::ActiveRecordError)
            expect_any_instance_of(Teacher).to_not receive(:restore!)

            expect{student.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not restore teacher when one of students get restored, in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(6).last

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(teacher.students.first.bury!).to be true
            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect{teacher.students.first.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 1
            expect(Student.where_buried.count).to eql 1
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

        end

      end

    end

  end

end
