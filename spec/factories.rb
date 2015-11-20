FactoryGirl.define do

  factory :user do

    sequence :name do |u|
      "name#{u}"
    end

    sequence :email do |e|
      "roundtableapps#{e}@gmail.com"
    end

  end

  factory :article do

    association :user, factory: :user

    sequence :title do |u|
      "title#{u}"
    end

    sequence :body do |e|
      "body#{e}"
    end

  end

  factory :review do

    association :article, factory: :article

    sequence :body do |e|
      "body#{e}"
    end

  end

  factory :issue do

    association :user, factory: :user

    sequence :title do |u|
      "title#{u}"
    end

    sequence :body do |e|
      "body#{e}"
    end

  end

  factory :patch do

    association :issue, factory: :issue

    sequence :name do |e|
      "body#{e}"
    end

  end

  factory :business do

    association :user, factory: :user

    sequence :name do |e|
      "name#{e}"
    end

  end

  factory :comment do

    association :business, factory: :business

    sequence :body do |e|
      "body#{e}"
    end

  end

  factory :customer do

    association :business, factory: :business

    sequence :name do |e|
      "name#{e}"
    end

  end

  factory :phone_number do

    association :user, factory: :user

    sequence :number do |e|
      "0912{e}"
    end

  end

  factory :building do

    sequence :name do |u|
      "name#{u}"
    end

  end

  factory :floor do

    association :building, factory: :building

    sequence :name do |u|
      "name#{u}"
    end

  end

  factory :column do

    association :floor, factory: :floor

    sequence :name do |u|
      "name#{u}"
    end

  end

  factory :school do

    sequence :name do |e|
      "name#{e}"
    end

  end

  factory :teacher do

    association :school, factory: :school

    sequence :name do |e|
      "name#{e}"
    end

  end

  factory :student do

    association :teacher, factory: :teacher

    sequence :name do |e|
      "name#{e}"
    end

  end

  factory :address do

    association :user, factory: :user

    sequence :line1 do |e|
      "address#{e}"
    end

  end

  factory :coordinate do

    association :address, factory: :address

    sequence :latitude do |e|
      "1#{e}.2".to_f
    end

    sequence :longitude do |e|
      "2#{e}.2".to_f
    end

  end

end
