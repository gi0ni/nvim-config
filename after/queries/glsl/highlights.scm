;; extends
; NOTE: You can use `:InspectTree` in the editor. It shows you the parse tree for the current buffer

((identifier) @core.token
	(#has-ancestor? preproc_call)
	(#eq? @core.token "core")
)

((identifier) @discard.token
			  (#eq? @discard.token "discard")
)

; ((layout_specification) @layout.specifier
; 	(#set! "priority" 200)
; )
