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

        context :bury do

            it 'should bury user, and all articles bond to that' do

              articles

              expect(user.articles.where_not_buried.count).to be 3

              user.bury

              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            it 'should bury user, and all articles bond to user, and all reviews bound to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              user.bury

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            it 'should bury article, and all reviews bound to that' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              expect(Article.first.bury).to be true

              expect(Article.where_buried.count).to be 1
              expect(Review.where_buried.count).to be 3
              expect(Article.first.buried?).to be true
              expect(user.buried?).to be false

            end

            it 'should bury review' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              expect(Review.first.bury).to be true

              expect(Review.where_buried.count).to be 1
              expect(Article.where_buried.count).to be 0

            end



            it 'should bury user, and all articles bond to user, and all reviews bond to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              user.bury

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            context :on_failure do

              it 'should rollback buried records, if something went wrong( in case of user ) ( from user point of view )' do

                articles
                reviews

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

                expect(user.bury).to be false

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end


              it 'should rollback buried records, if something went wrong( in case of article ) ( from user point of view )' do

                articles
                reviews

                raise_error = allow_instance_of(Article).with_id(articles.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                expect(user.bury).to be false

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of review ) ( from user point of view )' do

                articles
                reviews

                raise_error = allow_instance_of(Review).with_id(reviews.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                expect(user.bury).to be false

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of article ) ( from article point of view )' do

                articles
                reviews

                article = articles.first(2).last
                raise_error = allow_instance_of(Article).with_id(article.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                expect(article.bury).to be false

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of review ) ( from article point of view )' do

                articles
                reviews

                review = reviews.first(2).last
                raise_error = allow_instance_of(Review).with_id(review.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                expect(review.article.bury).to be false

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

            end
        end

        context :bury! do

            it 'should bury user, and all articles bond to that' do

              articles

              expect(user.articles.where_not_buried.count).to be 3

              user.bury!

              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            it 'should bury user, and all articles bond to user, and all reviews bound to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              user.bury!

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            it 'should bury article, and all reviews bound to that' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              expect(Article.first.bury!).to be true

              expect(Article.where_buried.count).to be 1
              expect(Review.where_buried.count).to be 3
              expect(Article.first.buried?).to be true
              expect(user.buried?).to be false

            end

            it 'should bury review' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              expect(Review.first.bury!).to be true

              expect(Review.where_buried.count).to be 1
              expect(Article.where_buried.count).to be 0

            end



            it 'should bury user, and all articles bond to user, and all reviews bond to articles' do

              articles
              reviews

              expect(Review.where_not_buried.count).to be 9
              expect(Article.where_not_buried.count).to be 3

              user.bury!

              expect(Review.where_buried.count).to be 9
              expect(user.articles.where_buried.count).to be 3
              expect(user.buried?).to be true

            end

            context :on_failure do

              it 'should rollback buried records, if something went wrong( in case of user ) ( from user point of view )' do

                articles
                reviews

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

                expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end


              it 'should rollback buried records, if something went wrong( in case of article ) ( from user point of view )' do

                articles
                reviews

                raise_error = allow_instance_of(Article).with_id(articles.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of review ) ( from user point of view )' do

                articles
                reviews

                raise_error = allow_instance_of(Review).with_id(reviews.first(2).last.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3

                expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(user.articles.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of article ) ( from article point of view )' do

                articles
                reviews

                article = articles.first(2).last
                raise_error = allow_instance_of(Article).with_id(article.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                expect{article.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3
                expect(user.buried?).to be false

                raise_error.redo!

              end

              it 'should rollback buried records, if something went wrong( in case of review ) ( from article point of view )' do

                articles
                reviews

                review = reviews.first(2).last
                raise_error = allow_instance_of(Review).with_id(review.id).raise(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3

                expect{review.article.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

                expect(Review.where_not_buried.count).to be 9
                expect(Article.where_not_buried.count).to be 3
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

        context :bury do

          it 'should bury user and all businesses bond to that' do

            user
            businesses

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0

            expect(user.bury).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3

          end

          it 'should bury user and all business bond to that & keep all comments bond to businesses' do

            user
            businesses
            comments

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

            expect(user.bury).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0

          end

          it 'should bury user and all business bond to that & bury all customers bond to businesses' do

            user
            businesses
            comments
            customers

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            expect(user.bury).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          it 'should bury comment, and bury business bond to comment' do

            businesses
            comments

            business = businesses.first
            comment = business.comments.first

            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            expect(comment.bury).to be true

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 1
            expect(Comment.where_buried.count).to eql 1
            expect(Customer.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should rollback buried records in case of invalid business' do

              businesses

              business = businesses.first(3).last
              raise_error = allow_instance_of(Business).with_id(business.id).raise(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              expect(user.bury).to be false

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should rollback buried records in case of invalid user' do

              businesses

              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              expect(user.bury).to be false

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end

        end

        context :bury do

          it 'should bury user and all businesses bond to that' do

            user
            businesses

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0

            expect(user.bury!).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3

          end

          it 'should bury user and all business bond to that & keep all comments bond to businesses' do

            user
            businesses
            comments

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0

            expect(user.bury!).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0

          end

          it 'should bury user and all business bond to that & bury all customers bond to businesses' do

            user
            businesses
            comments
            customers

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            expect(user.bury!).to be true

            expect(user.buried?).to be true
            expect(Business.where_buried.count).to eql 3
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

          end

          it 'should bury comment, and bury business bond to comment' do

            businesses
            comments

            business = businesses.first
            comment = business.comments.first

            expect(Business.where_buried.count).to eql 0
            expect(Comment.where_buried.count).to eql 0
            expect(Customer.where_buried.count).to eql 0

            expect(comment.bury!).to be true

            expect(user.buried?).to be false
            expect(Business.where_buried.count).to eql 1
            expect(Comment.where_buried.count).to eql 1
            expect(Customer.where_buried.count).to eql 0

          end

          context :on_failure do

            it 'should rollback buried records in case of invalid business' do

              businesses

              business = businesses.first(3).last
              raise_error = allow_instance_of(Business).with_id(business.id).raise(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

            it 'should rollback buried records in case of invalid user' do

              businesses

              raise_error = allow_instance_of(User).with_id(user.id).raise(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0

              expect{user.bury!}.to raise_error(ActiveRecord::ActiveRecordError)

              expect(Business.where_buried.count).to eql 0
              expect(Comment.where_buried.count).to eql 0
              expect(Customer.where_buried.count).to eql 0
              expect(user.buried?).to be false

              raise_error.redo!

            end

          end

        end

      end
    end
  end
end
