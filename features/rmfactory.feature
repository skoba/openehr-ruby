Feature: RMFactory generates RM insntances
  In order to generate RM instance by archetype definition
  As RM factory
  RM Type and attributes should be specified

  Scenario: RMFactory generates DvText instance
    Given "DV_TEXT" in archetype definition with attribute
    When RM Factory generates instance
    Then DvText instance should be available
