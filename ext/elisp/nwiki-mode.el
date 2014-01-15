;; from "How do I rename an open file in Emacs?"
;; http://stackoverflow.com/questions/384284/how-do-i-rename-an-open-file-in-emacs
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun nwiki-get-buffer-text ()
  (buffer-substring-no-properties (point-min) (point-max)))

(defun nwiki-extract-title (text)
  (let ((first-line (first (split-string text "\n"))))
    (replace-regexp-in-string "^\*+ +" "" first-line)))

(defun nwiki-sync-buffername-with-title ()
  "sync buffername with title"
  (interactive)
  (let ((file-name-from-title (concat
                               (nwiki-extract-title(nwiki-get-buffer-text))
                               ".org"))
        (buffer-file-name-without-directory (file-name-nondirectory buffer-file-name)))
    (unless (equal file-name-from-title buffer-file-name-without-directory)
      (rename-file-and-buffer file-name-from-title))))

(defun nwiki-add-this-buffer ()
  "add this buffer to repository"
  (shell-command (format "git add %s" buffer-file-name)))

(defun nwiki-commit-this-buffer ()
  "commit this buffer to repository"
  (shell-command "git commit --no-edit"))

(defun nwiki-add-and-commit-this-buffer ()
  "add and commit this buffer to repository"
  (nwiki-add-this-buffer)
  (nwiki-commit-this-buffer))

(defun nwiki-sync-and-commit ()
  "sync and commit this-buffer"
  (interactive)
  (nwiki-sync-buffername-with-title)
  (nwiki-add-and-commit-this-buffer))
