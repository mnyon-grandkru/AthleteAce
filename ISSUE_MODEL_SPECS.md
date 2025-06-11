# Issue: Implement Remaining Model Specs

## Overview
Create comprehensive specs for all models in the application. Currently, only the Ace model has a detailed spec implementation. This issue tracks the work needed for the remaining models.

## Models to Spec
- [ ] Achievement
- [ ] City
- [ ] Conference
- [ ] Country
- [ ] Division
- [ ] Federation
- [ ] GameAttempt
- [ ] Goal
- [ ] Highlight
- [ ] League
- [ ] Membership
- [ ] Player
- [ ] Position
- [ ] Quest
- [ ] Rating
- [ ] Role
- [ ] Spectrum
- [ ] Sport
- [ ] Stadium
- [ ] State
- [ ] Team

## Requirements for Each Model
1. Test all associations
2. Test all validations
3. Test all scopes
4. Test all instance methods
5. Test all class methods
6. Test edge cases and invalid inputs
7. Follow RSpec best practices
8. Maintain 100% coverage for model methods

## Current Status
- ✅ Ace model spec implemented (WIP, some failures to fix)
- ❌ All other models need specs

## Next Steps
1. Fix remaining Ace model spec failures
2. Create specs for core models first:
   - Player
   - Team
   - League
   - Sport
3. Create specs for supporting models
4. Create specs for game-related models
5. Create specs for location models

## Notes
- Use the Ace model spec as a reference for implementation style
- Ensure factories are properly set up for each model
- Focus on business logic and edge cases
- Document any complex test scenarios