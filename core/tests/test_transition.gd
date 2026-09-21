extends Node2D

func _ready() -> void:
	print("--- Running Chapter 0 to Chapter 1 Transition Test Scene ---")
	var dialog_scene = load("res://dialog/dialog.tscn")
	assert(dialog_scene != null, "Failed to load dialog scene")
	
	var dialog_instance = dialog_scene.instantiate()
	add_child(dialog_instance)
	
	# Wait for ready and prologue splash setup
	for i in 10:
		await get_tree().process_frame
		
	print("Initial chapter: ", dialog_instance._active_chapter)
	assert(dialog_instance._active_chapter == "chapter_0", "Expected chapter_0 initially")
	
	# Fast-forward Chapter 0 splash if playing
	if dialog_instance.chapter_splash.visible:
		dialog_instance.chapter_splash._skip()
		await dialog_instance.chapter_splash.finished
		await get_tree().process_frame
			
	print("Chapter 0 active. Triggering skip transition to Chapter 1...")
	dialog_instance._on_skip_pressed()
	
	# Let transition curtain tween execute until chapter_1 splash starts
	while dialog_instance._active_chapter != "chapter_1":
		await get_tree().process_frame
		
	print("After transition, chapter is: ", dialog_instance._active_chapter)
	assert(dialog_instance._active_chapter == "chapter_1", "Expected chapter_1 after transition")
	
	print("Chapter 1 splash visible: ", dialog_instance.chapter_splash.visible)
	assert(dialog_instance.chapter_splash.visible == true, "Chapter 1 splash should be playing")
	
	# Fast-forward Chapter 1 splash
	dialog_instance.chapter_splash._skip()
	await dialog_instance.chapter_splash.finished
	await get_tree().process_frame
		
	print("After Chapter 1 splash finished, dialog panel visible: ", dialog_instance.dialog_panel.visible)
	assert(dialog_instance.dialog_panel.visible == true, "Dialog panel should be visible for Chapter 1 line 0")
	print("First speaker in Chapter 1: ", dialog_instance.speaker_label.text)
	assert(dialog_instance.speaker_label.text == "Narrator", "Expected Narrator as first speaker in Chapter 1")
	
	print("--- TEST CASE 1 (SKIP): PASSED ---")
	dialog_instance.queue_free()
	await get_tree().process_frame

	print("--- TEST CASE 2: Verifying Card Claim Modal Transition to Chapter 1 ---")
	var dialog_instance_2 = dialog_scene.instantiate()
	add_child(dialog_instance_2)
	for i in 10:
		await get_tree().process_frame

	if dialog_instance_2.chapter_splash.visible:
		dialog_instance_2.chapter_splash._skip()
		await dialog_instance_2.chapter_splash.finished
		await get_tree().process_frame

	var ch0_lines: Array = dialog_instance_2._current_dialog.get("lines", [])
	dialog_instance_2.current_line_index = ch0_lines.size() - 1
	dialog_instance_2.display_current_line()
	await get_tree().process_frame

	print("Claim modal visible: ", dialog_instance_2.claim_card_modal.visible)
	assert(dialog_instance_2.claim_card_modal.visible == true, "ClaimCardModal should be visible on last line")

	print("Triggering Claim button...")
	dialog_instance_2.claim_card_modal._on_claim_pressed()

	while dialog_instance_2._active_chapter != "chapter_1":
		await get_tree().process_frame

	print("After claim transition, chapter is: ", dialog_instance_2._active_chapter)
	assert(dialog_instance_2._active_chapter == "chapter_1", "Expected chapter_1 after card claim")
	assert(dialog_instance_2.chapter_splash.visible == true, "Chapter 1 splash should be playing")

	dialog_instance_2.chapter_splash._skip()
	await dialog_instance_2.chapter_splash.finished
	await get_tree().process_frame

	assert(dialog_instance_2.dialog_panel.visible == true, "Dialog panel should be visible for Chapter 1")
	print("--- TEST CASE 2 (CARD CLAIM): PASSED ---")

	print("--- ALL CHAPTER TRANSITION TESTS PASSED SUCCESSFULLY! ---")
	get_tree().quit(0)
