require 'spec_helper'

describe :Persistence do
  
  let(:user) do
    create(:user)
  end
  
  context(:buried?) do
    
    it 'should return true if #buried_at is not nil' do
      user.bury
      expect(user.buried_at).to_not be_nil
      expect(user.buried?).to be true
    end
    
    it 'should return false if #buried_at is nil' do
      expect(user.buried_at).to be_nil
      expect(user.buried?).to be false
    end
    
  end

  context :bury do
    
    it 'should bury a record' do
      expect(user.buried?).to eql false
      user.bury
      expect(user.buried?).to eql true
    end
  
    it 'should return false if something went wrong' do
      allow(user).to receive(:save!).and_raise(StandardError)
      expect(user.bury).to eql false
    end 
    
  end
  
  context(:bury!) do
    
    it 'should bury a record' do
      expect(user.buried?).to eql false
      user.bury!
      expect(user.buried?).to eql true
    end
    
    it 'should raise exception if something went wrong' do
      allow(user).to receive(:save!).and_raise(StandardError)
      expect{user.bury!}.to raise_error(StandardError)
    end
    
  end
  

end