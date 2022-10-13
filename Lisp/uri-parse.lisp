;;; --Mode: Lisp --

(defun uri-parse (stringa)

  (let* ((uri (coerce stringa 'list ))

         (p (position #\: uri))
	 
	 (scheme (split-sx uri p ()))
	 
         (special (special-scheme scheme))         
	 
	 (uri-scheme (split-dx uri p ())))
    
    (cond ((= 1 special) (uri-mailto uri-scheme))
          ((= 2 special) (uri-news uri-scheme))
          ((= 3 special) (uri-tel-fax uri-scheme))
          ((= 3 special) (uri-tel-fax uri-scheme))
          ((= 4 special) (uri-zos uri-scheme scheme))
          (t (uri-parse1 uri-scheme scheme)))))

(defun uri-parse1 (uri-scheme scheme)

  ;;Trasforma la Stringa in una lista di chars
  (let* ((aut-presence (autp uri-scheme)) 

	 ;;post-slash è la lista senza gli slash
	 (uri-slash (del-slash uri-scheme aut-presence))

	 ;;Presenza di userinfo (1/0)
	 (user-presence (check-userinfo uri-scheme aut-presence))

	 ;;Estrae userinfo  
	 (userinfo (split-bool uri-slash '#\@ user-presence))

	 (uri-userinfo (if (= user-presence 1) (rest (diff userinfo uri-slash))
                         (diff userinfo uri-slash)))
	 ;;Estrae host         
	 (host (ch uri-userinfo aut-presence))
	 
	 (uri-host (diff host uri-userinfo))

	 ;;Presenza di post (1/0)
         (port-presence (check-port-aux uri-host aut-presence))

	 ;;Estrae port                
         (port (if (eq nil (check-port uri-host port-presence)) '80
                 (check-port uri-host port-presence)))

         (uri-port (cond ((eq '80 port) uri-host)
                         ((= port-presence 1) (diff port (rest uri-host)))
                         (diff port uri-host)))

	 ;;Verifica cosa è presente dopo tra Path/Query/Fragment
         (next (check-next uri-port))

	 ;;Estrae path         
         (path (check-path uri-port next))

         (uri-path (diff path uri-port))
         
         (next (check-next uri-path))

	 ;;Estrae query
         (query (rest (check-query uri-path next)))
         
         (uri-query (diff query (rest uri-path)))

	 ;;Estrae fragment
         (fragment (rest (check-fragment uri-query))))
    
    ;;Controlli sulle sezioni dell'uri
    (check-id scheme)
    (check-id userinfo)
    (host-dot-check host host)
    (port-digits port)
    (check-id-path path)
    (path-slash-check path)
    (check-id-query query)

    (uri-structure scheme userinfo host port path query fragment)
    ))

(defun uri-mailto (uri-scheme)

  (let* ((userinfo (if (contains uri-scheme '#\@)
                       (split-bool uri-scheme '#\@ 1)
                     uri-scheme))
         (uri-userinfo (diff userinfo uri-scheme))

         (host (if (eq (car uri-userinfo) #\@) (rest uri-userinfo)
                 nil))

         (scheme nil)
         (port '80)
         (path nil)
         (query nil)
         (fragment nil))
    
    (check-id userinfo)
    (check-id-host host)
    (host-dot-check host host)
    (uri-structure scheme userinfo host port path query fragment)))

(defun uri-news (uri-scheme)
  (let ((host uri-scheme))

    (check-id-host host)
    (host-dot-check host host)
    (uri-structure nil nil host '80 nil nil nil)))

(defun uri-tel-fax (uri-scheme)
  (let ((userinfo uri-scheme))
    (check-id userinfo)
    
    (check-id userinfo)
    (uri-structure nil userinfo nil '80 nil nil nil)))


(defun uri-zos (uri-scheme scheme)

  (let* ((aut-presence (autp uri-scheme)) 

	 (uri-slash (del-slash uri-scheme aut-presence))

	 (user-presence (check-userinfo uri-scheme aut-presence))
	 
	 (userinfo (split-bool uri-slash '#\@ user-presence))

	 (uri-userinfo (if (= user-presence 1) (rest (diff userinfo uri-slash))
                         (diff userinfo uri-slash)))
         
	 (host (ch uri-userinfo aut-presence))
	 
	 (uri-host (diff host uri-userinfo))

         (port-presence (check-port-aux uri-host aut-presence))
         
         (port (if (eq nil (check-port uri-host port-presence)) '80
                 (check-port uri-host port-presence)))

         (uri-port (cond ((eq '80 port) uri-host)
                         ((= port-presence 1) (diff port (rest uri-host)))
                         (diff port uri-host)))

         (next (check-next uri-port))
	 
         (path (if (car (check-path uri-port next))
                   (rest (check-path uri-port next))
                 (check-path uri-port next)))

         (uri-path (if (eq '#\/ (car uri-port)) 
                       (diff path (rest uri-port))
                     (diff path uri-port)))
         
         (next (check-next uri-path))

         (query (rest (check-query uri-path next)))
         
         (uri-query (diff query (rest uri-path)))

         (fragment (rest (check-fragment uri-query))))
    
    (check-id scheme)
    (check-id userinfo)
    (host-dot-check host host)
    (port-digits port)
    (is-path-zos path)
    (check-id-query query)

    (uri-structure scheme userinfo host port path query fragment)
    ))

(defun uri-scheme (str)
  (if (eq nil (car str)) nil
    (coerce (car str) 'string)))

(defun uri-userinfo (str)
  (if (eq nil (second str)) nil
    (coerce (second str) 'string)))

(defun uri-host (str)
  (if (eq nil (third str)) nil
    (coerce (third str) 'string)))

(defun uri-port (str)
  (if (eq '80 (fourth str)) '80
    (parse-integer (coerce (fourth str) 'string))))

(defun uri-path (str)
  (if (eq nil (fifth str)) nil
    (coerce (fifth str) 'string)))

(defun uri-query (str)
  (if (eq nil (sixth str)) nil
    (coerce (sixth str) 'string)))

(defun uri-fragment (str)
  (if (eq nil (seventh str)) nil
    (coerce (seventh str) 'string)))

;;; divide la stringa all'elemento in posizione pos
;;; ritorna la parte sinistra della stringa (senza l'elemento a pos)
(defun split-sx (str pos sx)
  (if  (<= pos 0) sx
    (cons (car str) (split-sx (rest str) (- pos 1) sx))))

;;; come sopra ma per la parte destra
(defun split-dx (str pos dx)
  (cond ((null str) dx)
        ((< pos 0)
         (cons (car str) (split-dx (rest str) (- pos 1) dx)))
        ((>= pos 0)
         (split-dx (rest str)(- pos 1) dx))))

;;; Split-sx con booleano 
(defun split-bool (str y bool)
  (if (= bool 1)
      (split-sx str (position y str) ())
    nil))

;;; verifica se la lista contiene x
(defun contains (l x)
  (cond((null l) nil)
       ((eq (car l) x) t)
       (t (contains (rest l) x))))

(defun not-contains (l x)
  (cond ((null l) t)
        ((eq (car l) x) nil)
        (t (not-contains (rest l) x))))

;;; verifica se la lista in input rispetta i criteri
;;; dell'identificatore
(defun check-id (str)
  (cond ((null str) t)
        ((eq (car str) '#\/) (error "Identificatore errato!"))
        ((eq (car str) '#\#) (error "Identificatore errato!"))
        ((eq (car str) '#\?) (error "Identificatore errato!"))
        ((eq (car str) '#\@) (error "Identificatore errato!"))
        ((eq (car str) '#\:) (error "Identificatore errato!"))
        (t (check-id (rest str)))))

;;; check-id per l'host
(defun check-id-host (str)
  (cond ((null str) t)
        ((eq (car str) '#\/) (error "Host errato!"))
        ((eq (car str) '#\#) (error "Host errato!"))
        ((eq (car str) '#\?) (error "Host errato!"))
        ((eq (car str) '#\@) (error "Host errato!"))
        ((eq (car str) '#\:) (error "Host errato!"))
        (t (check-id-host (rest str)))))

(defun check-id-query (str)
  (cond ((null str) t)
        ((eq (car str) '#\#) (error "Query errata!"))
        (t (check-id-query (rest str)))))


;;; verifica la presenza di autorithy 1 per True, 0 per False
(defun autp (str)
  (if (and (eq (first str) #\/)
           (eq (second str) #\/))
      1   
    0))

;;; verifica se è presente l'userinfo, se no ritorna la lista intera
(defun check-userinfo (str bool)
  (if (and (contains str '#\@)
           (= 1 bool)) 1
    0))

;;; rimuove gli slash dell'authority
(defun del-slash (str bool)
  (if (= 1 bool) (rest(rest str))
    str))

;;: Elimina la prima occorrenza della lista l1 in l2
(defun diff (l1 l2)
  (if (null l1) l2
    (if (eq (car l1) (car l2))
	(diff (rest l1) (rest l2)))))

;;; Se è presente, estrae e controlla host
(defun ch (str bool)
  (cond ((= 0 bool) nil)
        ((contains str #\:)
         (split-sx str  (position #\: str) ()))
        ((contains str #\/)
         (split-sx str (position #\/ str) ()))
        ((contains str #\?)
         (split-sx str (position #\? str) ()))
        ((contains str #\#)
         (split-sx str (position #\? str) ()))
        (t str)))

;;; Verifica che host rispetti i criteri 
(defun check-host (str)
  (let ((host (ch str 1)))     
    (is-host2 host)))

;;; Funzione ausiliare a check-host
(defun is-host (str)
  (cond ((eq nil str) t)
        ((contains str #\.) 
         (let ((a (split-sx str (position #\. str) ())))
           (check-id-host a)
           (is-host (diff a str))))
        ((not-contains str #\.) (check-id-host str))))

(defun is-host2 (str)
  (check-id-host str))

;;; Controlla i punti dell'host
(defun host-dot-check (str &optional str2)
  (cond ((eq nil str) t)
        ((eq '#\. (car str2)) (error "Host non valido"))
        ((eq '#\. (car (last str2))) (error "Host non valido"))
        ((and (eq (car str) #\.)
              (eq (second str) #\.))
         (error "host non valido"))
        (t (host-dot-check (rest str)))))

;;; Controlla la presenza del port
(defun check-port-aux (str aut)
  (cond ((= 0 aut) 0)
        ((eq (car str) '#\:) 1)
	(t 0)))
;;; Estrae il port
(defun check-port (str port-presence)
  (cond ((= 0 port-presence) nil)
        ((contains str #\/) (rest (split-bool str #\/ port-presence)))
        ((contains str #\?) (rest (split-bool str #\? port-presence)))
        ((contains str #\/) (rest (split-bool str #\# port-presence)))
        (t (rest str))))
;;; Controlla che il port sia composto da digits
(defun port-digits (str)
  (cond ((eq nil str) t)
        ((numberp str) t)
        ((char-digits (car str)) (port-digits (rest str)))
        (t (error "Il port non è è composto da digits!"))))

(defun char-digits (char)
  (cond ((eq char #\0) t)
        ((eq char #\1) t)
        ((eq char #\2) t)
        ((eq char #\3) t)
        ((eq char #\4) t)
        ((eq char #\5) t)
        ((eq char #\6) t)
        ((eq char #\7) t)
        ((eq char #\8) t)
        ((eq char #\9) t)
        ))


;;; Controlla cosa si trova dopo tra Fine/Path/Query/Fragment
(defun check-next (str)
  (cond ((eq (car str) '#\/) 1)
        ((eq (car str) '#\?) 2)
        ((eq (car str) '#\#) 3)
        (t 1)))

;;; Estrae path se next = 1
(defun check-path (str bool)
  (cond ((and (= 1 bool) (contains str #\?))
         (split-sx str (position #\? str) ()))
        ((and (= 1 bool) (contains str #\#))
         (split-sx str (position #\# str) ()))
        ((= 1 bool) str)
        (t nil)))

(defun is-path (str)
  (cond ((eq nil str) t)
        ((contains str #\/) 
         (let ((a (split-sx str (position #\/ str) ())))
           (check-id a)
           (is-path (diff a str))))
        ((not-contains str #\/) (check-id-host str))))

(defun check-id-path (str)
  (cond ((null str) t)
        ((eq (car str) '#\#) (error "Port errato!"))
        ((eq (car str) '#\?) (error "Port errato!"))
        ((eq (car str) '#\@) (error "Port errato!"))
        ((eq (car str) '#\:) (error "Port errato!"))
        (t (check-id-path (rest str)))))

(defun path-slash-check (str)
  (cond ((eq nil str) t)
	((and (eq (car str) #\/)
              (eq (second str) #\/))
         (error "Path non valido"))
        (t (path-slash-check (rest str)))))

;;Funzioni per il riconoscimento del path zos
(defun check-path-zos (str bool)
  (cond ((and (contains str #\?)
              (= 1 bool))
         (split-sx str (position #\? str) ()))
        ((and (contains str #\#)
              (= 1 bool))
         (split-sx str (position #\# str) ()))
        (t nil)))

(defun is-path-zos (str)
  (let* ((id44 (if (contains str '#\( )
                   (split-sx str (position '#\( str) ())
                 str))
         (id8 (if (contains str '#\( )
                  (split-dx str (position '#\( str) ())
                nil)))

    (cond ((> (length id44) '44)
           (error "Id44 troppo lungo!"))
          ((> (length id8) '9)
           (error "Id8 troppo lungo!"))
          ((and (contains str '#\( )
                (not-contains str '#\) ))
           (error "Le parentesi di path non sono bilanciate!"))
          (t 

	   (check-id44 id44)
	   (check-id8 id8)))))

(defun check-id44 (str)
  (cond ((eq nil str) t)
        ((eq '#\. (car str))
         (check-id44 (rest str)))
        ((alphanumericp (car str))
         (check-id44 (rest str)))
        (t (error "Id44 errato!"))))

(defun check-id8 (str)
  (cond ((eq nil str) t)
        ((and (eq '#\) (car str))
              (eq '#\) (car (last str))))
         (check-id8 (rest str)))         
        ((alphanumericp (car str))
         (check-id8 (rest str)))
        (t (error "Id8 non valido!"))))

;;;Estrae query
(defun check-query (str bool)
  (cond ((and (= 2 bool) (contains str #\#))
         (split-sx str (position #\# str) ()))
        ((= 2 bool) str)
        (t nil)))

;;;Estrae fragment
(defun check-fragment (str)
  (if (eq (car str) #\#) str
    nil))

(defun uri-write (scheme userinfo host port path query fragment)
  (format t "Scheme: ~A ~%" (if (eq nil scheme) nil
                              (coerce scheme 'string)))
  (format t "Userinfo: ~A ~%" (if (eq nil userinfo) nil
                                (coerce userinfo 'string)))
  (format t "Host: ~A ~%" (if (eq nil host) nil
                            (coerce host 'string)))
  (format t "Port: ~A ~%" (if (eq '80 port) '80
                            (parse-integer (coerce port 'string))))
  (format t "Path: ~A ~%" (if (eq nil path) nil
                            (coerce path 'string)))
  (format t "Query: ~A ~%" (if (eq nil query) nil
                             (coerce query 'string)))
  (format t "Fragment: ~A" (if (eq nil fragment) nil
                             (coerce fragment 'string)))
  )

(defun uri-display (uri &optional (stream t))

  (format t "Scheme: ~A ~%" (uri-scheme uri))
  (format t "Userinfo ~A ~%" (uri-userinfo uri))
  (format t "Host: ~A ~%" (uri-host uri))
  (format t "Port: ~A ~%" (uri-port uri))
  (format t "Path: ~A ~%" (uri-path uri))
  (format t "Query: ~A ~%" (uri-query uri))
  (format t "Fragment: ~A ~%" (uri-fragment uri))
  )



(defun special-scheme (str)
  (let ((scheme (coerce str 'string)))
    (cond ((string= scheme "mailto") 1)
          ((string= scheme "news") 2)
          ((string= scheme "tel") 3)
          ((string= scheme "fax") 3)
          ((string= scheme "zos") 4)
          (t 0))))

(defun uri-structure (scheme userinfo host port path query fragment)
  (list scheme userinfo host port path query fragment))