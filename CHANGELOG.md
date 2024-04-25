# 2.3.0
## Weapon Shake
A new feature has been added which makes weapon idle shake. This allows for realistic effects, like inexperienced operators not able to keep the gun steady. It is configured in the Weapon.ShakeIntensity field, and can be controlled using a hook LSCalculateShakeIntensity(Weapon) that returns a multiplier (this only runs when ShakeIntensity is configured).

## Sway effects
The sway effect has been redone. Due to this, the SwayDrag effect looks worse and we advise not to use it.

## Falloff
Bullet falloff has been added. This makes it so shooting from long distances is less accurate due to gravity and wind, and requires the scope to be adjusted.