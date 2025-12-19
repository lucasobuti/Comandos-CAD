(defun c:TPL_PLOT (/ ss rectList rows rowRects tolerance num plotter paper ctb path *error*)

  (vl-load-com)
  (setq tolerance 10.0) ; tolerância vertical entre linhas
  (setq num 1)

  ;; ================================
  ;; CONFIGURAÇÕES PERSONALIZÁVEIS
  ;; ================================
  (setq plotter "DWG To PDF.pc3") ; ou "AutoCAD PDF (High Quality Print).pc3"
  (setq paper "ISO_full_bleed_A4_(297.00_x_210.00_MM)")
  (setq ctb "acad.ctb")
  (setq path "C:\\Users\\PC\\Documents\\obuti\\Unifilar\\Teste\\")
  (if (/= (substr path (strlen path)) "\\") (setq path (strcat path "\\")))
  (if (not (vl-file-directory-p path)) (vl-mkdir path))

  ;; ================================
  ;; FUNÇÃO DE ERRO
  ;; ================================
  (defun *error* (msg)
    (princ (strcat "\nErro: " msg))
    (setvar "cmdecho" 1)
    (setvar "osmode" 0)
    (princ)
  )

  ;; ================================
  ;; SELEÇÃO DOS RETÂNGULOS
  ;; ================================
  (prompt "\nSelecionando retângulos da layer RECTANGLE...")
  (setq ss (ssget "X" '((0 . "LWPOLYLINE") (8 . "RECTANGLE"))))

  (if (not ss)
    (progn (princ "\nNenhum retângulo encontrado na layer 'RECTANGLE'.") (exit))
  )

  ;; ================================
  ;; COLETAR COORDENADAS DOS RETÂNGULOS
  ;; ================================
  (setq rectList
    (mapcar
      (function
        (lambda (e)
          (setq ed (entget e))
          (setq pts (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) ed)))
          (setq xs (mapcar 'car pts))
          (setq ys (mapcar 'cadr pts))
          (list e
                (/ (+ (apply 'min xs) (apply 'max xs)) 2.0) ; X centro
                (/ (+ (apply 'min ys) (apply 'max ys)) 2.0) ; Y centro
                (apply 'min xs) (apply 'min ys)
                (apply 'max xs) (apply 'max ys))
        )
      )
      (vl-remove-if 'null (mapcar 'cadr (ssnamex ss)))
    )
  )

  ;; ================================
  ;; AGRUPAR POR LINHAS (Y)
  ;; ================================
  (setq rectList (vl-sort rectList '(lambda (a b) (> (caddr a) (caddr b))))) ; ordenar por Y decrescente

  (setq rows '())
  (foreach r rectList
    (setq y (caddr r))
    (if (not rows)
      (setq rows (list (list y r)))
      (if (< (abs (- y (caar rows))) tolerance)
        (setq rows (cons (append (list (caar rows)) (cons r (cdr (car rows)))) (cdr rows)))
        (setq rows (cons (list y r) rows)))
    )
  )

  ;; Corrige a ordem das linhas (de cima p/ baixo)
  (setq rows (vl-sort rows '(lambda (a b) (> (car a) (car b)))))

  ;; ================================
  ;; ORDENAR DENTRO DE CADA LINHA (X crescente)
  ;; ================================
  (setq orderedList '())
  (foreach row rows
    (setq rowRects (cdr row))
    (setq rowRects (vl-sort rowRects '(lambda (a b) (< (cadr a) (cadr b)))))
    (setq orderedList (append orderedList rowRects))
  )

  (prompt (strcat "\n" (itoa (length orderedList)) " retângulos encontrados. Iniciando plots..."))

  ;; ================================
  ;; PLOTAGEM AUTOMÁTICA
  ;; ================================
  (foreach r orderedList
    (setq e (car r))
    (setq minx (nth 3 r))
    (setq miny (nth 4 r))
    (setq maxx (nth 5 r))
    (setq maxy (nth 6 r))
    (setq p1 (list minx miny))
    (setq p2 (list maxx maxy))
    (setq pdfName (strcat path "PAG" (if (< num 10) "0" "") (itoa num) ".pdf"))

    (command "-plot" "Y" "model" plotter paper "M" "L" "N" "W" p1 p2 "fit" "C" "Y" ctb "Y" "A" pdfName "Y" "Y")
    (princ (strcat "\nPlotado: " pdfName))
    (setq num (1+ num))
  )

  (princ (strcat "\n\nPlotagem concluída!\nArquivos salvos em: " path))
  (princ)
)
