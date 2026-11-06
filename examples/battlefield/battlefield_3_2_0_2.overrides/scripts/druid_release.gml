// druid_release();
// Called by a Druid when it dies or is removed: undoes Ironskin and Survival Instincts and stops Rake.
/////////////////////////////////////////////////////////////////////////////////////////////////////
if(_ironskin_active) {
    _ironskin_active = false;
    _damagereduction -= _ironskin_damagereduction;
}
if(_survivalinstincts_active) {
    _survivalinstincts_active = false;
    _maxhealth -= _survivalinstincts_health;
    _health = min(_health, _maxhealth);
    _survivalinstincts_health = 0;
}
_rake_timer = 0;
_rake_target = -1;
