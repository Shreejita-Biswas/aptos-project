module HealthSystem::PreventiveHealthRewards {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    /// Error codes
    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 2;
    
    /// Struct to track a user's health activities and rewards
    struct HealthProfile has key {
        activities_completed: u64,  // Number of health activities completed
        rewards_earned: u64,        // Total rewards earned (in token units)
    }
    
    /// Function to register a user in the preventive health reward system
    public fun register_user(user: &signer) {
        let user_addr = signer::address_of(user);
        
        // Check if user is already registered
        assert!(!exists<HealthProfile>(user_addr), E_ALREADY_REGISTERED);
        
        // Create new health profile with zero activities and rewards
        let health_profile = HealthProfile {
            activities_completed: 0,
            rewards_earned: 0,
        };
        
        // Move the profile to the user's account
        move_to(user, health_profile);
    }
    
    /// Function to record a health activity and distribute rewards
    public fun record_activity(
        user: &signer, 
        reward_provider: &signer,
        activity_points: u64, 
        reward_amount: u64
    ) acquires HealthProfile {
        let user_addr = signer::address_of(user);
        let provider_addr = signer::address_of(reward_provider);
        
        // Ensure user has a health profile
        assert!(exists<HealthProfile>(user_addr), E_NOT_INITIALIZED);
        
        // Get user's health profile
        let health_profile = borrow_global_mut<HealthProfile>(user_addr);
        
        // Update the profile with new activity and rewards
        health_profile.activities_completed = health_profile.activities_completed + activity_points;
        health_profile.rewards_earned = health_profile.rewards_earned + reward_amount;
        
        // Transfer the reward from provider to user
        let reward = coin::withdraw<AptosCoin>(reward_provider, reward_amount);
        coin::deposit<AptosCoin>(user_addr, reward);
    }
}