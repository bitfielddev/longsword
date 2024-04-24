# 2.3.0
## Scope Shake
A new feature has been added which makes shaking scopes possible. This allows for realistic effects, like inexperienced operators not able to keep the gun steady. It is configured in the Attachment.Scope.ShakeIntensity, and can be controlled using a hook LSCalculateShakeIntensity(Weapon) that returns a multiplier (this only runs when ShakeIntensity is configured).

