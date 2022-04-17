<?php
	if(!defined('DS')) { define('DS', DIRECTORY_SEPARATOR); }
	$output = $argv[1];
	$root =
		__DIR__ . DS . // web
			'..' . DS .    // gambit
			'..' . DS .    // dmcblue
			'..' . DS .    // src
			'..';
	require $root . DS . "vendor" . DS . "autoload.php";
	$dotenv = Dotenv\Dotenv::createImmutable($root);
	$dotenv->load();
	$LANG = $_ENV["GAMBIT_LANG"];
	$BASE_URL = $_ENV["GAMBIT_UI_BASE_URL"];
	$TITLE = "Gambit";
	$description = "Gambit is a game";
	$date = (new \DateTime())->format('c');
	$tags = ["game", "boardgame", "gambit"];
	$metadata_image = "opengraph.png";
	switch($LANG) {
		case "en-US": $LOCALE = "en_US";
	}
	ob_start();
?><!DOCTYPE html>
<html lang="<?php echo $LANG; ?>">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width,initial-scale=1.0">
		<style>
			@-ms-viewport{
				width: device-width;
			}
		</style>
		<link rel="icon" href="<?php echo $BASE_URL; ?>/assets/gambit.png">
		<link rel="canonical" href="<?php echo $BASE_URL; ?>/index.html" />
		<meta name="robots" content="max-snippet:-1, max-image-preview:large, max-video-preview:-1"/>

		<link href="<?php echo $BASE_URL; ?>/assets/style.css" rel="stylesheet" type="text/css">
		<!-- Fonts -->
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@300&family=Open+Sans:ital,wght@0,400;0,600;1,400;1,600&display=swap" rel="stylesheet"> 
		<!-- END Fonts -->

		<title><?php echo $TITLE; ?></title>
		<meta name="description" content="<?php echo $description; ?>" />		
		<?php foreach($tags as $tag): ?>
			<meta property="article:tag" content="<?php echo $tag; ?>" />
		<?php endforeach; ?>
		<meta property="article:published_time" content="2022-04-01T00:00:00" />
		<meta property="article:modified_time" content="<?php echo $date; ?>" />

		<meta property="og:title" content="<?php echo $TITLE; ?>" />
		<meta property="og:type" content="website" />
		<meta property="og:url" content="<?php echo $BASE_URL; ?>" />
		<meta property="og:image" content="<?php echo $metadata_image; ?>" />
		<meta property="og:description" content="<?php echo $description; ?>" />
		<meta property="og:locale" content="<?php echo $LOCALE; ?>" />
		<meta property="og:updated_time" content="<?php echo $date; ?>" />

		<meta name="twitter:card" content="summary_large_image">
		<meta name="twitter:site" content="@dmcblue">
		<meta name="twitter:creator" content="@dmcblue">
		<meta name="twitter:title" content="<?php echo $TITLE; ?>">
		<meta name="twitter:description" content="<?php echo $description; ?>">
		<meta name="twitter:image" content="<?php echo $metadata_image; ?>">

			<?php
			
			$schema = [
				"@context" => "https://schema.org",
				"@graph" => [
					[
						"@type" => "WebSite",
						"@id" => $BASE_URL,
						"url" => $BASE_URL,
						"name" => "dmcblue",
						"publisher" => [
							"@id" => $BASE_URL
						]
					],[
						"@type" => "ImageObject",
						"@id" => $metadata_image,
						"url" => $metadata_image,
						"width" => 1273,
						"height" => 775
					],[
						"@type" => "WebPage",
						"@id" => "/",
						"url" => "/",
						"inLanguage" => $LANG,
						"name" => $TITLE,
						"isPartOf" => [
							"@id" => $BASE_URL
						],
						"primaryImageOfPage" => [
							"@id" => $metadata_image
						],
						"datePublished" => "2022-04-01T00:00:00",
						"dateModified" => $date
					],[
						"@type" => "Article",
						"@id" => "/",
						"isPartOf" => [
							"@id" => "/"
						],
						"author" => [
							"@id" => "https://www.dmcblue.com/about"
						],
						"headline" => $TITLE,
						"datePublished" => "2022-04-01T00:00:00",
						"dateModified" => $date,
						"commentCount" => 0,
						"mainEntityOfPage" => [
							"@id" => "/"
						],
						"publisher" => [
							"@id" => "https://www.dmcblue.com/about"
						],
						"image" => [
							"@id" => $metadata_image
						],
						"keywords" => implode(',', $tags),
						"articleSection" => ""
					],[
						"@type" => ["Person"],
						"@id" => "https://www.dmcblue.com/about",
						"name" => "dmcblue",
						"image" => [
							"@type" => "ImageObject",
							"@id" => $metadata_image,
							"url" => $metadata_image,
							"caption" => "dmcblue"
						],
						"sameAs" => []
					]
				]
			];
		?><script type='application/ld+json'><?php echo json_encode($schema); ?></script>
	</head>
	<body>
		<div id="app">
			<section class="page-row page-row-expanded main">
				<div id="underground"></div>
				<div>
					<div id="text-space">
						<div id="text"></div><!--
						--><div id="error">
							<span id="error_close">X</span>
							<p id="error_message"></p>
						</div><!--
						--><div id="start" class="component">
							<button id="start_create">Create</button>
							<button id="start_join">Join</button>
						</div>
						<div id="create" class="component">
							<button id="start_human">Human</button>
							<button id="start_ai">AI</button>
						</div>
						<div id="ai_level" class="component">
							<button id="ai_level_easy">Easy</button>
							<button id="ai_level_medium">Medium</button>
							<button id="ai_level_hard">Hard</button>
						</div>
						<div id="team" class="component">
							<button id="team_black">Black (Goes first)</button>
							<button id="team_white">White (Goes second)</button>
						</div>
						<div id="invite" class="component">
							<input id="invite_game_id" type="text" autocomplete="off"/>
							<button id="invite_game_id_done">Go</button>
						</div>
						<div id="play_again" class="component">
							<button id="play_again_yes">Yes</button>
							<button id="play_again_no">No</button>
						</div>
						<div id="pass_option" class="component">
							<button id="pass">
								Pass
							</button>
						</div>
					</div>
					<div id="play" class="component">
						<div id="background"></div>
						<div id="board"><!--
						<?php foreach(['A', 'B', 'C', 'D'] as $index => $rowName): ?>
						--><div class="row"><!--
							<?php foreach(range(0, 7) as $colName): ?>
								--><div id="<?php echo $rowName . $colName; ?>" class="cell">
									<div class="piece black" style="background-position: <?php echo ($colName * -100); ?>px <?php echo ($index * -100); ?>px;"></div>
									<div class="piece white" style="background-position: <?php echo ($colName * -100); ?>px <?php echo ($index * -100); ?>px;"></div>
									<div class="choice"></div>
									<div class="chosen"></div>
								</div><!--
							<?php endforeach; ?>
						--></div><!--
						<?php endforeach; ?>
						--></div>
					</div>
				</div>
			</section>
			<section id="description">
				<span id="description_close">X</span>
				<div>
					<h2>Rules</h2>

					<p>
						The board is 8 spaces wide and 4 spaces deep. The two (2) players face each other along the 8 space wide sides of the board, with 4 spaces between them.
					</p>
					<p>
						A line of 8 pieces for each player are setup one piece away from the player, like:
					</p>
					<code>
 Player X

----------
|        |
|XXXXXXXX|
|OOOOOOOO|
|        |
----------

 Player O
					</code>
					<p>
						Each player takes turns making moves.
					</p>
					<p>
						Pieces are moved by jumping over a single piece of the opposing team in a straight line in any direction (orthogonal or diagonal) onto an empty space.
						The piece that has been jumped over is removed from the board.
					</p>
					<p>
						If a subsequent move is available, the same piece can make multiple jumps in a row before the turn is over. Multiple jumps is optional, so a player can pass after the first jump even if moves are available. But a player must make at least one jump per turn.
						The subsequent moves do not have to be in the same direction as the original jump.
					</p>
					<p>
						The game ends when any player is unable to make a move on their turn.
						The board is then scored.
					</p>
					<p>
						Players earn points for each island of pieces they have on the board.
						An island is a group of piece from the same side that does not touch any pieces of the opposing player, including diagonally.
						Scores are by the number of pieces per island, added up for all islands for a player.
					</p>
					<p>
						Scores per island:
					</p>
					<dl>
						<dt>1 piece</dt><dd>1 point</dd>
						<dt>2 pieces</dt><dd>3 points</dd>
						<dt>3 pieces</dt><dd>5 points</dd>
						<dt>4 pieces</dt><dd>7 points</dd>
						<dt>5 pieces</dt><dd>9 points</dd>
					</dl>
					<p>
						The player with the most points wins.
					</p>
						</div>
			</section>
			<footer class="page-row">
				<div>
					Gambit
					<span id="help">?</span>
				</div>
			</footer>
		</div>
		<script src="<?php echo $BASE_URL; ?>/gambit.js"></script>
	</body>
</html><?php

$page = ob_get_contents();
ob_end_clean();
file_put_contents($output, $page);
