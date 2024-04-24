# 2.3.0
## Weapon Shake
A new feature has been added which makes weapon idle shake. This allows for realistic effects, like inexperienced operators not able to keep the gun steady. It is configured in the Weapon.ShakeIntensity field, and can be controlled using a hook LSCalculateShakeIntensity(Weapon) that returns a multiplier (this only runs when ShakeIntensity is configured).

