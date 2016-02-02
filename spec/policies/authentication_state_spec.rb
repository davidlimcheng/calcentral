describe AuthenticationState do

  describe '#directly_authenticated?' do
    subject {AuthenticationState.new(fake_session).directly_authenticated?}
    context 'when normally authenticated' do
      let(:fake_session) {{
        'user_id' => random_id
      }}
      it {should be true}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        'user_id' => random_id,
        'original_user_id' => random_id
      }}
      it {should be false}
    end
    context 'when delegate viewing as' do
      let(:fake_session) {{
        'user_id' => random_id,
        'original_delegate_user_id' => random_id
      }}
      it {should be false}
    end
    context 'when advisor viewing as' do
      let(:fake_session) {{
        'user_id' => random_id,
        'original_advisor_user_id' => random_id
      }}
      it {should be false}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        'user_id' => random_id,
        'lti_authenticated_only' => true
      }}
      it {should be false}
    end
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be_nil}
    end
  end

  describe '#real_user_id' do
    subject {AuthenticationState.new(fake_session).real_user_id}
    context 'when normally authenticated' do
      let(:fake_session) {{
        'user_id' => random_id
      }}
      it {should eq fake_session['user_id']}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        'user_id' => random_id,
        'original_user_id' => random_id
      }}
      it {should eq fake_session['original_user_id']}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        'user_id' => random_id,
        'lti_authenticated_only' => true
      }}
      it {should eq AuthenticationState::LTI_AUTHENTICATED_ONLY}
    end
    context 'when authenticated from an external app under masquerade' do
      let(:fake_session) {{
        'user_id' => random_id,
        'lti_authenticated_only' => true,
        'canvas_masquerading_user_id' => random_id
      }}
      it {should eq "#{AuthenticationState::LTI_AUTHENTICATED_ONLY}: masquerading Canvas ID #{fake_session['canvas_masquerading_user_id']}"}
    end
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be_nil}
    end
  end

  describe '#viewing_as?' do
    subject {AuthenticationState.new(fake_session).viewing_as?}
    context 'when normally authenticated' do
      let(:fake_session) {{
        'user_id' => random_id
      }}
      it {should be false}
    end
    context 'when viewing as' do
      let(:fake_session) {{
        'user_id' => random_id,
        'original_user_id' => random_id
      }}
      it {should be true}
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        'user_id' => random_id,
        'lti_authenticated_only' => true
      }}
      it {should be false}
    end
    context 'when not logged in' do
      let(:fake_session) {{
      }}
      it {should be false}
    end
  end

  describe '#delegate_viewing_as?' do
    subject {AuthenticationState.new fake_session}
    context 'when authenticated but not a delegate' do
      let(:fake_session) {{
        'user_id' => random_id
      }}
      it 'should not find delegate session attribute' do
        expect(subject.authenticated_as_delegate?).to be false
        expect(subject.delegate_permissions).to be_nil
      end
    end
    context 'when in delegate-view-as mode' do
      let(:user_id) { random_id }
      let(:campus_solutions_id) { '23009422' }
      let(:fake_session) {{
        'user_id' => user_id,
        'original_delegate_user_id' => random_id
      }}
      before do
        allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return double(lookup_campus_solutions_id: campus_solutions_id)
      end
      it 'should get student of delegate user' do
        expect(subject).to be_authenticated_as_delegate
        permissions = subject.delegate_permissions
        expect(permissions).to_not be_nil
        expect(permissions[:fullName]).to eq 'Tom Tulliver'
        expect(permissions[:campusSolutionsId]).to eq campus_solutions_id
        expect(permissions[:privileges]).to eq({
           financial: false,
           viewEnrollments: false,
           viewGrades: false,
           phone: true
         })
      end
    end
    context 'when in advisor-view-as mode' do
      let(:user_id) { random_id }
      let(:fake_session) {{
        'user_id' => user_id,
        'original_advisor_user_id' => random_id
      }}
      it 'should get student of advisor user' do
        expect(subject).to be_authenticated_as_advisor
      end
    end
    context 'when only authenticated from an external app' do
      let(:fake_session) {{
        'user_id' => random_id,
        'lti_authenticated_only' => true
      }}
      it 'should force delegate session to false' do
        expect(subject.authenticated_as_delegate?).to be false
        expect(subject.delegate_permissions).to be_nil
      end
    end
    context 'when not logged in' do
      let(:fake_session) { {} }
      it 'should force delegate session to false' do
        expect(subject.authenticated_as_delegate?).to be false
        expect(subject.delegate_permissions).to be_nil
      end
    end
  end
end
