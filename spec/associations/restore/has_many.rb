require 'spec_helper'

describe :Associations do

  describe :has_many do

    describe 'dependent: :destroy' do

      context('User, Article, Review') do

        let(:user) do
          create(:user)
        end

        let(:articles) do
          create_list(:article, 3, user_id: user.id)
        end

        let(:reviews) do
          articles.each do |article|
            create_list(:review, 3, article: article)
          end

          Review.all
        end

        context :restore do

            it 'should restore user, and all articles bond to that' do

              articles

              expect(user.articles.where_not_buried.count).to be 3

              # In case of bury
              user.bury
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              user.restore
              expect(user.articles.where_buried.count).to be 0
              expect(user.buried?).to be false

            end

            it 'should restore user, and all articles bond to user, and all reviews bound to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of bury
              user.bury
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              user.restore
              expect(Review.where_buried.count).to be 0
              expect(user.articles.where_buried.count).to be 0
              expect(user.buried?).to be false

            end

            it 'should restore article, and all reviews bound to that' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of bury
              expect(Article.first.bury).to be true
              expect(Article.where_buried.count).to be 1
              expect(Review.where_buried.count).to be 3
              expect(Article.first.buried?).to be true
              expect(user.buried?).to be false

              # In case of restore
              expect(Article.first.restore).to be true
              expect(Article.where_buried.count).to be 0
              expect(Review.where_buried.count).to be 0
              expect(Article.first.buried?).to be false
              expect(user.buried?).to be false

            end

            it 'should restore review' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of bury
              expect(Review.first.bury).to be true
              expect(Review.where_buried.count).to be 1
              expect(Article.where_buried.count).to be 0

              # In case of restore
              expect(Review.first.restore).to be true
              expect(Review.where_buried.count).to be 0
              expect(Article.where_buried.count).to be 0

            end



            it 'should restore user, and all articles bond to user, and all reviews bond to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of bury
              user.bury
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              user.restore
              expect(Review.where_buried.count).to be 0
              expect(user.articles.where_buried.count).to be 0
              expect(user.buried?).to be false

            end

            context :on_failure do

              it 'should rollback restored records, if something went wrong( in case of user ) ( from user point of view )' do

                articles
                reviews

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                # In case of bury
                expect(user.bury).to be
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                # In case of restore
                raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

                expect(user.restore).to be false
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                raise_error.redo!

              end


              it 'should rollback restored records, if something went wrong( in case of article ) ( from user point of view )' do

                articles
                reviews

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                # In case of bury
                expect(user.bury).to be true
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                # In case of restore
                raise_error = allow_instance_of(Article).with_id(articles.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(user.restore).to be false
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                raise_error.redo!

              end

              it 'should rollback restored records, if something went wrong( in case of review ) ( from user point of view )' do

                articles
                reviews

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                # In case of bury
                expect(user.bury).to be true
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                # In case of restore
                raise_error = allow_instance_of(Review).with_id(reviews.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(user.restore).to be false
                expect(Review.where_buried.count).to be 9
                expect(user.articles.where_buried.count).to be 3
                expect(user.buried?).to be true

                raise_error.redo!

              end

              it 'should rollback restored records, if something went wrong( in case of article ) ( from article point of view )' do

                articles
                reviews

                article = articles.first(2).last

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                # In case of bury
                expect(article.bury).to be true
                expect(Review.where_buried.count).to be 3
                expect(Article.where_buried.count).to be 1
                expect(user.buried?).to be false

                # In case of restore
                raise_error = allow_instance_of(Article).with_id(article.id).raise(ActiveRecord::ActiveRecordError)

                expect(article.restore).to be false
                expect(Review.where_buried.count).to be 3
                expect(Article.where_buried.count).to be 1
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback restored records, if something went wrong( in case of review ) ( from article point of view )' do

                articles
                reviews

                review = reviews.first(2).last

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                # In case of buried
                expect(review.article.bury).to be true
                expect(Review.where_buried.count).to be 3
                expect(Article.where_buried.count).to be 1
                expect(user.buried?).to be false

                # In case of restore
                raise_error = allow_instance_of(Review).with_id(review.id).raise(ActiveRecord::ActiveRecordError)

                expect(review.article.restore).to be false
                expect(Review.where_buried.count).to be 3
                expect(Article.where_buried.count).to be 1
                expect(user.buried?).to be false

                raise_error.redo!

              end

            end
        end

        context :restore! do

          it 'should restore user, and all articles bond to that' do

            articles

            expect(user.articles.where_not_buried.count).to be 3

            # In case of bury
            user.bury!
            expect(user.articles.where_buried.count).to be 3
            expect(user.buried?).to be true

            # In case of restore
            user.restore!
            expect(user.articles.where_buried.count).to be 0
            expect(user.buried?).to be false

          end

          it 'should restore user, and all articles bond to user, and all reviews bound to articles' do

            articles
            reviews

            expect(Review.where_not_buried.count).to be 9
            expect(Article.where_not_buried.count).to be 3

            # In case of bury
            user.bury!
            expect(Review.where_buried.count).to be 9
            expect(user.articles.where_buried.count).to be 3
            expect(user.buried?).to be true

            # In case of restore
            user.restore!
            expect(Review.where_buried.count).to be 0
            expect(user.articles.where_buried.count).to be 0
            expect(user.buried?).to be false

          end

          it 'should restore article, and all reviews bound to that' do

            articles
            reviews

            expect(Review.where_not_buried.count).to be 9
            expect(Article.where_not_buried.count).to be 3

            # In case of bury
            expect(Article.first.bury!).to be true
            expect(Article.where_buried.count).to be 1
            expect(Review.where_buried.count).to be 3
            expect(Article.first.buried?).to be true
            expect(user.buried?).to be false

            # In case of restore
            expect(Article.first.restore!).to be true
            expect(Article.where_buried.count).to be 0
            expect(Review.where_buried.count).to be 0
            expect(Article.first.buried?).to be false
            expect(user.buried?).to be false

          end

          it 'should restore review' do

            articles
            reviews

            expect(Review.where_not_buried.count).to be 9
            expect(Article.where_not_buried.count).to be 3

            # In case of bury
            expect(Review.first.bury!).to be true
            expect(Review.where_buried.count).to be 1
            expect(Article.where_buried.count).to be 0

            # In case of restore
            expect(Review.first.restore!).to be true
            expect(Review.where_buried.count).to be 0
            expect(Article.where_buried.count).to be 0

          end



          it 'should restore user, and all articles bond to user, and all reviews bond to articles' do

            articles
            reviews

            expect(Review.where_not_buried.count).to be 9
            expect(Article.where_not_buried.count).to be 3

            # In case of bury
            user.bury!
            expect(Review.where_buried.count).to be 9
            expect(user.articles.where_buried.count).to be 3
            expect(user.buried?).to be true

            # In case of restore
            expect(user.restore!).to be true
            expect(Review.where_buried.count).to be 0
            expect(user.articles.where_buried.count).to be 0
            expect(user.buried?).to be false

          end

          context :on_failure do

            it 'should rollback restored records, if something went wrong( in case of user ) ( from user point of view )' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(user.articles.where_not_buried.count).to be 3

              # In case of bury
              expect(user.bury!).to be
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              raise_error.redo!

            end


            it 'should rollback restored records, if something went wrong( in case of article ) ( from user point of view )' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(user.articles.where_not_buried.count).to be 3

              # In case of bury
              expect(user.bury!).to be true
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Article).with_id(articles.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should rollback restored records, if something went wrong( in case of review ) ( from user point of view )' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(user.articles.where_not_buried.count).to be 3

              # In case of bury
              expect(user.bury!).to be true
              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Review).with_id(reviews.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should rollback restored records, if something went wrong( in case of article ) ( from article point of view )' do

              articles
              reviews

              article = articles.first(2).last

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of bury
              expect(article.bury!).to be true
              expect(Review.where_buried.count).to be 3
              expect(Article.where_buried.count).to be 1
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Article).with_id(article.id).raise(ActiveRecord::ActiveRecordError)

              expect{article.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Review.where_buried.count).to be 3
              expect(Article.where_buried.count).to be 1
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should rollback restored records, if something went wrong( in case of review ) ( from article point of view )' do

              articles
              reviews

              review = reviews.first(2).last

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              # In case of buried
              expect(review.article.bury!).to be true
              expect(Review.where_buried.count).to be 3
              expect(Article.where_buried.count).to be 1
              expect(user.buried?).to be false

              # In case of restore
              raise_error = allow_instance_of(Review).with_id(review.id).raise(ActiveRecord::ActiveRecordError)

              expect{review.article.restore!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Review.where_buried.count).to be 3
              expect(Article.where_buried.count).to be 1
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end
        end

      end

    end

    describe 'dependent: :delete_all' do

      context('User, Business, [Comment, Customer]') do

        let(:user) do
          create(:user)
        end

        let(:businesses) do
          create_list(:business, 3, user: user)
        end

        let(:comments) do

          businesses.each do |business|
              create_list(:comment, 5, business: business)
          end

          Comment.all

        end

        let(:customers) do

          businesses.each do |business|
            create_list(:customer, 5, business: business)
          end

          Customer.all
        end

        context :restore do

          it 'should restore user and all businesses bond to that' do

            user
            businesses

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3

            # In case of restore
            expect(user.restore).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0


          end

          it 'should restore user and all business bond to that & keep all comments bond to businesses' do

            user
            businesses
            comments

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0

            # In case of restore
            expect(user.restore).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

          end

          it 'should restore user and all business bond to that & restore all customers bond to businesses' do

            user
            businesses
            comments
            customers

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of restore
            expect(user.restore).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          it 'should restore comment, and restore business bond to comment' do

            businesses
            comments

            business = businesses.first
            comment = business.comments.first

            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of bury
            expect(comment.bury).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 1
            expect(Comment.where_buried.count).to eql 1
            expect(Customer.where_buried.count).to eql 0

            # In case of restore
            expect(comment.restore).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should rollback restored records in case of invalid business' do

              businesses

              business = businesses.first(3).last

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              # In case of bury
              expect(user.bury).to be true
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Business).with_id(business.id).raise(ActiveRecord::ActiveRecordError)

              expect(user.restore).to be false
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should rollback restored records in case of invalid user' do

              businesses

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              # In case of bury
              expect(user.bury).to be true
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(user.restore).to be false
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

          end

        end

        context :restore! do

          it 'should restore user and all businesses bond to that' do

            user
            businesses

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3

            # In case of restore
            expect(user.restore!).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0


          end

          it 'should restore user and all business bond to that & keep all comments bond to businesses' do

            user
            businesses
            comments

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0

            # In case of restore
            expect(user.restore!).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

          end

          it 'should restore user and all business bond to that & restore all customers bond to businesses' do

            user
            businesses
            comments
            customers

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of bury
            expect(user.bury!).to be true
            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of restore
            expect(user.restore!).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          it 'should restore comment, and restore business bond to comment' do

            businesses
            comments

            business = businesses.first
            comment = business.comments.first

            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            # In case of bury
            expect(comment.bury!).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 1
            expect(Comment.where_buried.count).to eql 1
            expect(Customer.where_buried.count).to eql 0

            # In case of restore
            expect(comment.restore!).to be true
            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should rollback restored records in case of invalid business' do

              businesses

              business = businesses.first(3).last

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              # In case of bury
              expect(user.bury!).to be true
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(Business).with_id(business.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

            it 'should rollback restored records in case of invalid user' do

              businesses

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              # In case of bury
              expect(user.bury!).to be true
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              # In case of restore
              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect{user.restore!}.to raise_error(ActiveRecord::ActiveRecordError)
              
              expect(Business.where_not_buried.count).to eql 0
              expect(Comment.where_not_buried.count).to eql 0
              expect(Customer.where_not_buried.count).to eql 0
              expect(user.buried?).to be true

              raise_error.redo!

            end

          end

        end

      end
    end
  end
end
