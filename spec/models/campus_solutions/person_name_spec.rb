describe CampusSolutions::PersonName do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::PersonName.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        type: 'LEG',
        firstName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid and non-permitted fields' do
        expect(subject.keys.length).to eq 15
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:nameType]).to be_nil
        expect(subject[:firstName]).to eq 'Joe'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'LEG',
        firstName: 'Joe'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['NAMES']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['FIRST_NAME']).to eq 'Joe'
      end
      it 'should force the type to be PRF (preferred)' do
        expect(subject['NAME_TYPE']).to eq 'PRF'
      end
    end

    context 'performing a post' do
      let(:params) { {
        type: 'LEG',
        firstName: 'Joe'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
