extends Node

# warnings-disable

signal jumpscare(enemy: Enemy, area: String)
signal phantom_jumpscare()


signal flashlight_off()
signal flashlight_on()
signal update_flashlight_state(flashlight_state)

signal pickup_lumber()
signal lumber_despawned()

signal enemy_defended(enemy)
signal broadcast_sleep_assurance_score(score)
signal remove_sleep_assurance(delta,enemy)
signal activate_happyshroom()
signal start_happyshroom_fight()

signal go_to_sleep()
