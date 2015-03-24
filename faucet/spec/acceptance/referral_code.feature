Feature: Referral code

  Scenario: Sending referral code
    Given I am signed in
    When I see my profile
    And I create new referral code for 1 USD
    And I fund it
    And I send it
    Then I should see 'Email sent'


