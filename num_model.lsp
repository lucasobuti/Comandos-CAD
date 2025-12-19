(defun c:NumPag (/ ss textList groupedRows sortedList num tolerance)

  (setq textList '())

  ;; Collect TEXT entities in layer "PAGINA"
  (setq ss (ssget "X" '((0 . "TEXT") (8 . "PAGINA"))))
  (if ss
    (setq textList (append textList
                           (vl-remove-if 'null
                             (mapcar
                               (function (lambda (e)
                                           (if (wcmatch (cdr (assoc 1 (entget e))) "*PAG*")
                                             e)))
                               (mapcar 'cadr (ssnamex ss)))))))

  ;; Collect MTEXT entities in layer "PAGINA"
  (setq ss (ssget "X" '((0 . "MTEXT") (8 . "PAGINA"))))
  (if ss
    (setq textList (append textList
                           (vl-remove-if 'null
                             (mapcar
                               (function (lambda (e)
                                           (if (wcmatch (cdr (assoc 1 (entget e))) "*PAG*")
                                             e)))
                               (mapcar 'cadr (ssnamex ss)))))))

  (setq num 1
        tolerance 100
        groupedRows '())

  (if textList
    (progn
      ;; Make list of (entity . (x y))
      (setq sortedList
            (mapcar
              (function (lambda (e)
                          (cons e (cdr (assoc 10 (entget e))))))
              textList))

      ;; Sort by Y descending
      (setq sortedList
            (vl-sort sortedList
                     (function (lambda (a b)
                                 (> (cadr (cdr a)) (cadr (cdr b)))))))

      ;; Group by rows based on Y coordinate within tolerance
      (foreach item sortedList
        (setq added nil)
        (setq y (cadr (cdr item)))
        (setq groupedRows
          (mapcar
            (function (lambda (row)
                        (if (and (not added)
                                 (< (abs (- y (car row))) tolerance))
                          (progn
                            (setq added T)
                            (cons (car row) (cons item (cdr row))))
                          row)))
            groupedRows))
        (if (not added)
          (setq groupedRows (cons (cons y (list item)) groupedRows))))

      ;; Sort each row by X ascending
      (setq groupedRows
            (mapcar
              (function (lambda (row)
                          (cons (car row)
                                (vl-sort (cdr row)
                                         (function (lambda (a b)
                                                     (< (car (cdr a)) (car (cdr b)))))))))
              groupedRows))

      ;; Sort rows by Y descending
      (setq groupedRows
            (vl-sort groupedRows
                     (function (lambda (a b)
                                 (> (car a) (car b))))))

      ;; Flatten the list: row by row, column by column
      (setq sortedList (apply 'append (mapcar 'cdr groupedRows)))

      ;; Number and update entities
      (foreach pair sortedList
        (setq obj (car pair))
        (setq txt (entget obj))
        (setq txt (subst (cons 1 (strcat (if (< num 10) "0" "") (itoa num))) (assoc 1 txt) txt))
        (entmod txt)
        (entupd obj)
        (setq num (1+ num)))

      (princ "\nNumeração no Model concluída!")
    )
    (princ "\nNenhum texto 'PAG' encontrado na camada 'PAGINA'.")
  )
  (princ)
)
