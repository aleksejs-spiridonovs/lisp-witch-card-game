
;card number 0
;36 card deck values 6..A 0..8 9cards
;52 card deck values 2..A 0..12 13cards
;0 Spades 1 Hearts 2 Diamonds 3 Clubs



(defvar card-deck 36)
(defvar card-ring '())
(cond
	((= card-deck 36) (defvar bad-card 6)) ; SQ 0*9+6 = 6
	((= card-deck 52) (defvat bad-card -1))
	((T -1))
)
(defvar bad-card )

(defun cards-generate (number)
	(prog ()
		(setq l '())
		(loop for i from 0 to 35 do
			(push i l)
		)
		;(setf l (remove-if #'(lambda (X) (= X bad-card)) l))
		;(print l)
		(return l)
	)
)

(defun cards-randomize (c)
	(cond
		((= card-deck 36)
			(prog ()
				(setq len (list-length c))
				(loop for i from 0 to len do
					(setq rn1 (random-number len))
					;(print rn1)
					(setq rn2 (random-number len))
					;(print rn2)
					(setq swap 0)
					(setf swap (nth rn1 c))
					(setf c (replace-nth c rn1 (nth rn2 c)))
					(setf c (replace-nth c rn2 swap))
					;(print c)
				)
				(return c)
			)
		)
		(T -1)
	)
)


(defun cards-amount ( player )
	(length (gplayer-cards player))
)


(defun cards-output ( c )
	(prog ()
		(terpri)
		(dolist (cc c)
			(prin1 (format nil "~A " (cards-print-card cc)))
		)
	)
)


(defun cards-output-cat ( c )
	(prog ()
		(setq str "")
		(dolist (cc c)
			(setf str (concatenate 'string str (cards-print-card cc)))
		)
		(return str)
	)
)

;give all player cards at games start
(defun cards-give-to-players (pl c)
	(prog ()
		(setq number-of-cards (list-length c))
		(setq number-of-players (get-player-number))
		(setq number-per-player (floor (/ number-of-cards number-of-players)))
		(setq number-left (mod number-of-cards number-of-players))
		(dolist (player pl)
			(loop for m from 1 to number-per-player do
				(setq card (pop c))
				;(print card)
				(setf (gplayer-cards player) (push card (gplayer-cards player)))
			)
		)
		(loop for i from 0 to (- number-left 1) do
			(setf
				(gplayer-cards (nth i pl))
				(push (pop c) (gplayer-cards (nth i pl)))
			)
		)
	)
)

;check if player is looser
(defun cards-check ()
	(
	)
)


;throw cards from player, same cards
(defun cards-throw (c)
	(prog ()
		(setq for-remove '())
		(loop for i from 0 to (- (list-length c) 2) do
			(if (numberp (nth i c))
				(loop for j from (+ i 1) to (- (list-length c) 1) do
					(if (numberp (nth j c))
						(if (numberp (nth i c))
							(prog ()
								(if (and (= (mod (nth i c) 9) (mod (nth j c) 9)) (not (equal i j)))
									(prog ()
										(if (and (/= (nth i c) bad-card) (/= (nth j c) bad-card))
											(prog ()
												;(format t "~% Throw pair ~A ~A" (cards-print-card (nth i c)) (cards-print-card (nth j c)))
												(push (nth j c) for-remove)
												(push (nth i c) for-remove)
												(setf (nth j c) NIL)
												(setf (nth i c) NIL)
											)
										)
									)
								)
								(setf c (remove NIL c))
							)
						)
					)
				)
			)
		)
		(return c)
	)
)

(defun cards-throw-from-player ( p )
	(prog ()
		(setq cards (gplayer-cards (nth p player-ring)))
		(setf cards (cards-throw cards))
		(setf (gplayer-cards (nth p player-ring)) cards)
	)
)


;change cards between players
;get from player p1 card and put it inside p2
;if p1 has 1 card he not-looser
(defun cards-exchange ( p1 p2 )
	(prog ()
		;if same player
		;(print "IN card-exchange")
		;(print "ERR same player")
		(if (= p1 p2)
			(return-from cards-exchange)
		)
		;if players outside game
		;(
		;)
		;if first player hasnt cards
		;(print "ERR first no cards")
		(if (= (list-length (gplayer-cards (nth p1 player-ring))) 0)
			(return-from cards-exchange)
		)
		;if second player without cards
		;(print "ERR second no cards")
		(if (= (list-length (gplayer-cards (nth p2 player-ring))) 0)
			(return-from cards-exchange)
		)
		;if first player has only one card
		;(print "ERR first player 1 card")
		(if (= (list-length (gplayer-cards (nth p1 player-ring))) 1)
			(prog ()
				(print "ERR first player 1 card")
				(setf (gplayer-endgame (nth p1 player-ring)) T)
				(setf (gplayer-cards (nth p2 player-ring)) (push (nth 0 (gplayer-cards (nth p1 player-ring))) (gplayer-cards (nth p2 player-ring))))
				(setf (gplayer-cards (nth p1 player-ring)) '())
				(return-from cards-exchange)
			)
		)
		;if first player has more than 1 card
		;(print "More than 1 user")
		(setq p1-cards (gplayer-cards (nth p1 player-ring)))
		(setq p2-cards (gplayer-cards (nth p2 player-ring)))
		;(print (list-length p1-cards))
		(setq random-number (random-number (- (list-length p1-cards) 0)))
		(setq random-card (nth random-number p1-cards))
		(setf (gplayer-cards (nth p1 player-ring)) (remove-if #'(lambda (X) (= X random-card)) p1-cards))
		(setf (gplayer-cards (nth p2 player-ring)) (push random-card p2-cards))
		(return-from cards-exchange)
	)
)


;check if is player card
(defun cards-player-has (deck card)
	(if (find card deck) (not NIL) (not T))
)


(defun cards-nominal ( card )
	(cond
		((= card-deck 36) 
			(prog ()
				(setq n (mod card 9))
				(if (< n 5)
					(return (write-to-string (+ n 6)))
				)
				(cond
					((= n 5) (return "J"))
					((= n 6) (return "Q"))
					((= n 7) (return "K"))
					((= n 8) (return "A"))
				)
			)
		)
		((= card-deck 52) 
			(prog ()
				(setq n (mod card 13))
				(if (< n 9)
					(return (write-to-string (+ n 2)))
				)
				(cond 
					((= n 9) (return "J"))
					((= n 10) (return "Q"))
					((= n 11) (retrun "K"))
					((= n 12) (return "A"))
				)
			)
		)
	)
)


(defun cards-suit ( card )
	(cond
		((= card-deck 36) 
			(prog ()
				(setq n (floor (/ card 9)))
				(cond
					((= n 0) (return "S"))
					((= n 1) (return "H"))
					((= n 2) (return "D"))
					((= n 3) (return "C"))
				)
			)
		)
		((= card-deck 52) 
			(prog ()
				(setq n (floor (/ card 13)))
				(cond
					((= n 0) (return "S"))
					((= n 1) (return "H"))
					((= n 2) (return "D"))
					((= n 3) (return "C"))
				)
			)
		)
	)
)



(defun cards-print-card ( card )
	(
		concatenate 'string "[" (cards-suit card) (cards-nominal card) "]"
	)
)


;fix make not to be universal. For 2 card-decks
(defun cards-name-input ()
	(prog ()
		(setq r "!!!")
		(cond 
			((= card-deck 36) 
				(prog ()
					(setq run T)
					(loop while (not (not run)) do
						(print "Input card name ([SHDC][2-10]):")
						(setf card-name (string (read)))
						(if (stringp card-name)
							(prog ()
								(print "Thats string")
								(string-upcase card-name)
							)
						)
						(print card-name)
						(if (stringp card-name)
							(cond
								;if card name length 3
								((= (length card-name) 3) 
									(prog ()
										(print "Size3")
										(if (or (string= card-name "S10") (string= card-name "H10") (string= card-name "D10") (string= card-name "C10") ) 
											(prog ()
												(setf r card-name)
												(setf run (not T))
											)
										)
									)
								)
								;if card name length 2
								((= (length card-name) 2)
									(if (and (> (parse-integer card-name :start 1) 1) (< (parse-integer card-name :start 1) 10))
										(prog ()
											(setf r card-name)
											(setf run (not T))
										)
										(
											print "Incorect card name"
										)
									)
								)
								
							)
						)
					)
				)
			)
			((= card-deck 52) 
				(
				)
			)
			( T (return -1))
		)
		(return r)
	)
)

(defun replace-nth (list n elem)
	(cond 
		((null list) ())
		((= n 0) (cons elem (cdr list)))
		(T (cons(car list) (replace-nth (cdr list) (- n 1) elem)))
	)
)
