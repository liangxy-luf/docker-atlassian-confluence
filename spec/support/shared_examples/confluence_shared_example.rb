shared_examples 'an acceptable Confluence instance' do |database_examples|

  include_examples 'a minimal acceptable Confluence instance'

  describe 'Going through the setup process' do
    before :all do
      visit '/'
    end

    subject { page }

    context 'when visiting the root page' do
      it { expect(current_path).to match '/setup/setupstart.action' }
      it { is_expected.to have_css 'form[name=startform]' }
      it { is_expected.to have_button 'Start setup' }
    end

    context 'when manually setting up the instance' do
      before :all do
        within 'form[name=startform]' do
          click_button 'Start setup'
        end
      end

      it { expect(current_path).to match %r{^/setup/setuplicense.action} }
      it { is_expected.to have_css 'form[name=licenseform]' }
      it { is_expected.to have_field 'licenseString' }
      it { is_expected.to have_button 'Next' }
    end

    context 'when processing license setup' do
      before :all do
        within 'form[name=licenseform]' do
          fill_in 'licenseString', with: 'AAABiQ0ODAoPeNp1kk9TwjAQxe/9FJnxXKYpeoCZHqCtgsqfgaIO4yWELURD0tm0KN/eWOjYdvD68vbtb3dzM9GKTBgS2iOU9n3a7/pkHiXE96jvbNhho3XnWXBQBuKtyIVWQTxN4sV8MV7GTirMHk5QOZJTBsG91eITvPdJBEeQOgN0uNRHwIYtLKWGa1ocNoCzdGUATUA9h2uVdhjPxRGCHAtw5gXyPTMQsRwCn1Lf9XzXv3NqwVN2gGCZDBYWstLj70zgqSyad0fVWPXgJaClGUfB8KGXuG+rl1v3ab0euUOPvjofAlmD/XG8GJBY5YAZCtMa9Ze5MagVZAGKX/FVE4eyMDZtqrdgAq+19zJlWEr/Na0TXjkTx4KLjWzeKbyIjaAJE7aDYpa2tTSO+mvbCrBKo/ryate4Up9KfylnhjumhGEl0SCXzBjB1B9Q/QYhQulrH/fcue6svl1di8BwFFnZKAGTE3mGIalGksliJxTZVqTmvLF6fXxksjhzpkwaqP5s3fMDBMYhRDAtAhUAhcR3uL05YCxbclq7h1dNa+Nc+j4CFBrdN005oVlMN9yBlWeM4TlnrOhqX02j3'
          click_button 'Next'
        end
      end

      it { expect(current_path).to match %r{^/setup/setupdbchoice-start.action} }
      it { is_expected.to have_css 'form[name=standardform]' }
      it { is_expected.to have_css 'form[name=embeddedform]' }
    end

    context 'when processing database setup' do
      include_examples database_examples
    end

    context 'when processing content setup' do
      before :all do
        within 'form#demoChoiceForm' do
          click_button 'Example Site'
        end
      end

      it { expect(current_path).to match '/setup/setupusermanagementchoice-start.action' }
      it { is_expected.to have_css 'form[name=internaluser]' }
      it { is_expected.to have_button 'Manage users and groups within Confluence' }
    end

    context 'when processing user management setup' do
      before :all do
        within 'form[name=internaluser]' do
          click_button 'Manage users and groups within Confluence'
        end
      end

      it { expect(current_path).to match '/setup/setupadministrator-start.action' }
      it { is_expected.to have_css 'form[name=setupadministratorform]' }
      it { is_expected.to have_field 'username' }
      it { is_expected.to have_field 'fullName' }
      it { is_expected.to have_field 'email' }
      it { is_expected.to have_field 'password' }
      it { is_expected.to have_field 'confirm' }
      it { is_expected.to have_button 'Next' }
    end

    context 'when processing administrative account setup' do
      before :all do
        within 'form[name=setupadministratorform]' do
          fill_in 'username', with: 'admin'
          fill_in 'fullName', with: 'Continuous Integration Administrator'
          fill_in 'email', with: 'confluence@circleci.com'
          fill_in 'password', with: 'admin'
          fill_in 'confirm', with: 'admin'
          click_button 'Next'
        end
      end

      it { expect(current_path).to match '/setup/finishsetup.action' }
      it { is_expected.to have_link 'Start' }
    end

    context 'when processing successful setup' do
      before :all do
        click_link 'Start'
      end

      it { expect(current_path).to match '/display/ds/Welcome+to+Confluence' }
      # The acceptance testing comes to an end here since we got to the
      # Confluence dashboard without any trouble through the setup.
    end
  end

  describe 'Stopping the Confluence instance' do
    before(:all) { @container.kill_and_wait signal: 'SIGTERM' }

    it 'should shut down successful' do
      # give the container up to 5 minutes to successfully shutdown
      # exit code: 128+n Fatal error signal "n", ie. 143 = fatal error signal
      # SIGTERM.
      #
      # The following state check has been left out 'ExitCode' => 143 to
      # suppor CircleCI as CI builder. For some reason whether you send SIGTERM
      # or SIGKILL, the exit code is always 0, perhaps it's the container
      # driver
      is_expected.to include_state 'Running' => false
    end

    include_examples 'a clean console'
  end

end
