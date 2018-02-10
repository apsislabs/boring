RSpec.describe Boring do
  it "has a version number" do
    expect(Boring::VERSION).not_to be nil
  end

  let(:user)      { User.new }
  let(:presenter) { UserPresenter.new }

  context '#bind' do
    it 'binds to the correct class' do
      expect { presenter.bind(user: user) }.to_not raise_error
    end

    it 'raises an error when bound incorrectly' do
      expect { presenter.bind(user: Hash.new) }.to raise_error ArgumentError
    end
  end

  context 'with binding' do
    before(:each) { presenter.bind(user: user) }

    context 'delegate methods' do
      it 'calls delegate methods correctly' do
        expect(user).to receive(:birth_date).twice
        expect(presenter.birth_date).to eq(user.birth_date)
      end

      it 'raises an exception for undelegated methods' do
        expect { presenter.first_name }.to raise_error NoMethodError
      end
    end

    context 'presenter methods' do
      it 'calls presenter method' do
        expect(presenter.name).to include(user.first_name)
        expect(presenter.name).to include(user.last_name)
      end
    end
  end
end
