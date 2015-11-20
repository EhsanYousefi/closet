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

      context :bury do

        it 'should bury school and all teachers, and do not touch any student' do

          school_2
          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

          expect(school.buried?).to be false

          expect_any_instance_of(Student).to_not receive(:bury!)
          expect(school.bury).to be true

          expect(school.buried?).to be true
          expect(Teacher.where_buried.count).to eql 7
          expect(School.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 0


        end

        it 'should bury school if one of the teachers get buried' do

          school_2
          teachers

          expect(Teacher.where_buried.count).to eql 0
          expect(school.buried?).to be false

          teacher = teachers.first(4).last
          expect(teacher.bury).to be true

          expect(school.buried?).to be true
          expect(teacher.buried?).to be true
          expect(Teacher.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 1

        end

        it 'should bury student, and teacher bond to that without burying school' do

          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

          expect_any_instance_of(User).to_not receive(:bury!)

          student = students.first(5).last
          expect(student.bury).to be true

          expect(Teacher.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be true

        end

        context :on_failure do

          it 'should not bury school when one of the teacheres get deleted in case of invalid school' do

            teachers
            students

            raise_error = allow_instance_of(School).with_id(school.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(teachers.first(5).last.bury).to be false

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury school when one of the teacheres get deleted in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(5).last
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(teacher.bury).to be false

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury teacher when one of students get buried, in case of invalid student' do

            teachers
            students

            student = students.first(18).last
            raise_error = allow_instance_of(Student).with_id(student.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(student.bury).to be false

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury teacher when one of students get buried, in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(6).last
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect(teacher.students.first.bury).to be false

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

        end

      end

      context :bury! do

        it 'should bury school and all teachers, and do not touch any student' do

          school_2
          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0

          expect(school.buried?).to be false

          expect_any_instance_of(Student).to_not receive(:bury!)
          expect(school.bury!).to be true

          expect(school.buried?).to be true
          expect(Teacher.where_buried.count).to eql 7
          expect(School.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 0


        end

        it 'should bury school if one of the teachers get buried' do

          school_2
          teachers

          expect(Teacher.where_buried.count).to eql 0
          expect(school.buried?).to be false

          teacher = teachers.first(4).last
          expect(teacher.bury!).to be true

          expect(school.buried?).to be true
          expect(teacher.buried?).to be true
          expect(Teacher.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 1

        end

        it 'should bury student, and teacher bond to that without burying school' do

          teachers
          students

          expect(Teacher.where_buried.count).to eql 0
          expect(Student.where_buried.count).to eql 0
          expect(School.where_buried.count).to eql 0

          expect_any_instance_of(User).to_not receive(:bury!)

          student = students.first(5).last
          expect(student.bury!).to be true

          expect(Teacher.where_buried.count).to eql 1
          expect(Student.where_buried.count).to eql 1
          expect(School.where_buried.count).to eql 0
          expect(student.buried?).to be true

        end

        context :on_failure do

          it 'should not bury school when one of the teacheres get deleted in case of invalid school' do

            teachers
            students

            raise_error = allow_instance_of(School).with_id(school.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect{teachers.first(5).last.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury school when one of the teacheres get deleted in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(5).last
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect{teacher.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury teacher when one of students get buried, in case of invalid student' do

            teachers
            students

            student = students.first(18).last
            raise_error = allow_instance_of(Student).with_id(student.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect{student.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

          it 'should not bury teacher when one of students get buried, in case of invalid teacher' do

            teachers
            students

            teacher = teachers.first(6).last
            raise_error = allow_instance_of(Teacher).with_id(teacher.id).raise(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            expect{teacher.students.first.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

            expect(Teacher.where_buried.count).to eql 0
            expect(Student.where_buried.count).to eql 0
            expect(School.where_buried.count).to eql 0

            raise_error.redo!

          end

        end

      end

    end

  end

end
