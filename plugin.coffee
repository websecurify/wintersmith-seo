'use strict'

# ---
# ---
# ---

path = require 'path'

# ---
# ---
# ---

g_titles = {}
g_keywords = {}
g_descriptions = {}

# ---

g_alts = []

# ---
# ---
# ---

iterate = (env, contents) ->
	for key, value of contents
		unless value.filepath?
			iterate value
			
			# ---
			
			continue
			
		# ---
		
		continue unless value.metadata
		
		# ---
		
		continue if value.metadata.filename and (path.extname value.metadata.filename) not in ['.htm', '.html']
		
		# ---
		
		title = value.metadata.title ? env.locals?.title ? null
		keywords = value.metadata.keywords ? env.locals?.keywords ? null
		description = value.metadata.description ? env.locals?.description ? null
		
		# ---
		
		continue unless title and keywords and description
		
		# ---
		
		title ?= '__untitled__'
		keywords ?= '__unkeyworded__'
		description ?= '__undescribed__'
		
		# ---
		
		g_titles[title] ?= []
		g_titles[title].push value.filepath.full
		
		# ---
		
		for keyword in keywords.split(',')
			keyword = keyword.trim()
			
			# ---
			
			g_keywords[keyword] ?= []
			g_keywords[keyword].push value.filepath.full
			
		# ---
		
		g_descriptions[description] ?= []
		g_descriptions[description].push value.filepath.full
		
		# ---
		
		g_alts.push value.filepath.full if /!\[\]\(/.test(value.markdown ? '')
		
	# ---
	
	return null
	
# ---
# ---
# ---

report = (env, contents) ->
	for key, value of g_titles
		continue if value.length is 1
		
		# ---
		
		env.logger.error "Multiple pages with title #{JSON.stringify key}"
		
		# ---
		
		for page in value
			env.logger.info "\t#{page}"
			
	# ---
	
	env.logger.warn "Keywords density"
	
	for key, value of g_keywords
		env.logger.info "\t#{key}: #{value.length}"
		
	# ---
	
	for key in g_alts
		env.logger.error "Page with empty image alts at: #{key}"
		
	# ---
	
	return null
	
# ---
# ---
# ---

module.exports = (env, callback) ->
	env.registerGenerator 'seo', (contents, callback) ->
		err = iterate env, contents
		
		return callback err if err
		
		# ---
		
		err = report env, contents
		
		return callback err if err
		
		# ---
		
		return callback null
		
	# ---
	
	return callback null
	
# ---
