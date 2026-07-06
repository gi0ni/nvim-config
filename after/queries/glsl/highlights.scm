;; extends

((identifier) @core.token
	(#has-ancestor? preproc_call)
	(#eq? @core.token "core")
)

((layout_specification) @layout.specifier
	(#set! "priority" 200)
)
