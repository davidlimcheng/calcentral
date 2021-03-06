describe HubEdos::MyStudent do
  let(:options) { {} }
  subject {
    proxy = HubEdos::MyStudent.new(random_id, options)
    proxy.get_feed_internal
  }
  before do
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CC_PROFILE', anything).and_return('edit profile link')
  end
  context 'mock proxy' do
    it 'should return unfiltered feed' do
      expect(subject[:statusCode]).to eq 200
      # Verify preferred name
      expect(subject[:feed][:student]['names'][0]['type']['code']).to eq 'PRF'
    end
    context 'view-as session' do
      let(:fields) { %w(affiliations identifiers) }
      let(:options) { { include_fields: fields } }
      it 'should return filtered feed' do
        expect(subject[:statusCode]).to eq 200
        student = subject[:feed][:student]
        expect(student).to have(2).items
        expect(student).to include *fields
        expect(student['affiliations'][0]['status']['code']).to_not be_nil
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:editProfile]).to eq 'edit profile link'
      end
    end
  end
end
