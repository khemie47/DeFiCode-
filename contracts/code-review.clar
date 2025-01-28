;; DeFi Code Review and Rating System Smart Contract

;; Constants
(define-constant admin-owner tx-sender)
(define-constant error-item-not-found (err u100))
(define-constant error-access-denied (err u101))
(define-constant error-duplicate-review (err u102))
(define-constant error-invalid-input (err u103))
(define-constant error-overflow (err u104))

;; Data Variables
(define-data-var latest-code-id uint u0)
(define-data-var latest-feedback-id uint u0)

;; Define the structure of a code submission
(define-map code-submissions
  { code-id: uint }
  {
    author: principal,
    project-name: (string-ascii 64),
    release-tag: (string-ascii 32),
    quality-score: uint
  }
)

;; Define the structure of feedback
(define-map feedback-entries
  { feedback-id: uint }
  {
    code-id: uint,
    evaluator: principal,
    rating: uint,
    feedback-text: (string-ascii 256)
  }
)

;; Define collateral for evaluators
(define-map evaluator-collateral
  { evaluator: principal }
  { collateral-amount: uint }
)

;; Validation functions
(define-private (is-valid-string (str (string-ascii 64)))
  (and
    (not (is-eq str ""))
    (<= (len str) u64)
  )
)

(define-private (is-valid-tag (tag (string-ascii 32)))
  (and
    (not (is-eq tag ""))
    (<= (len tag) u32)
  )
)

(define-private (is-safe-addition (a uint) (b uint))
  (let
    (
      (sum (+ a b))
    )
    (> sum a)  ;; Check for overflow
  )
)

;; Submit a new code project for review
(define-public (submit-code-project (project-name (string-ascii 64)) (release-tag (string-ascii 32)))
  (let
    (
      (code-id (+ (var-get latest-code-id) u1))
    )
    ;; Input validation
    (asserts! (is-valid-string project-name) error-invalid-input)
    (asserts! (is-valid-tag release-tag) error-invalid-input)
    (asserts! (is-safe-addition (var-get latest-code-id) u1) error-overflow)
    
    (map-set code-submissions
      { code-id: code-id }
      {
        author: tx-sender,
        project-name: project-name,
        release-tag: release-tag,
        quality-score: u0
      }
    )
    (var-set latest-code-id code-id)
    (ok code-id)
  )
)

;; Stake tokens to become an evaluator
(define-public (deposit-evaluator-collateral (collateral-amount uint))
  (let
    (
      (current-collateral (default-to u0 (get collateral-amount (map-get? evaluator-collateral { evaluator: tx-sender }))))
    )
    ;; Input validation
    (asserts! (> collateral-amount u0) error-invalid-input)
    (asserts! (is-safe-addition current-collateral collateral-amount) error-overflow)
    
    (try! (stx-transfer? collateral-amount tx-sender (as-contract tx-sender)))
    (ok (map-set evaluator-collateral
      { evaluator: tx-sender }
      { collateral-amount: (+ current-collateral collateral-amount) }))
  )
)

;; Submit feedback for a code project
(define-public (submit-code-feedback (code-id uint) (rating uint) (feedback-text (string-ascii 256)))
  (let
    (
      (feedback-id (+ (var-get latest-feedback-id) u1))
      (code-project (unwrap! (map-get? code-submissions { code-id: code-id }) error-item-not-found))
      (evaluator-deposit (unwrap! (map-get? evaluator-collateral { evaluator: tx-sender }) error-access-denied))
    )
    ;; Input validation
    (asserts! (> code-id u0) error-invalid-input)
    (asserts! (and (>= rating u0) (<= rating u5)) error-invalid-input)
    (asserts! (not (is-eq feedback-text "")) error-invalid-input)
    (asserts! (<= (len feedback-text) u256) error-invalid-input)
    (asserts! (>= (get collateral-amount evaluator-deposit) u100) error-access-denied)
    (asserts! (is-safe-addition (var-get latest-feedback-id) u1) error-overflow)
    
    (map-set feedback-entries
      { feedback-id: feedback-id }
      {
        code-id: code-id,
        evaluator: tx-sender,
        rating: rating,
        feedback-text: feedback-text
      }
    )
    (var-set latest-feedback-id feedback-id)
    (ok (update-code-quality-score code-id rating))
  )
)

;; Update code project quality score based on feedback rating
(define-private (update-code-quality-score (code-id uint) (rating uint))
  (let
    (
      (code-project (unwrap! (map-get? code-submissions { code-id: code-id }) error-item-not-found))
      (current-score (get quality-score code-project))
    )
    ;; Validation
    (asserts! (is-safe-addition current-score rating) error-overflow)
    (let
      (
        (new-score (+ current-score rating))
      )
      (ok (map-set code-submissions
        { code-id: code-id }
        (merge code-project { quality-score: new-score })))
    )
  )
)

;; Get code project details
(define-read-only (get-code-project (code-id uint))
  (map-get? code-submissions { code-id: code-id })
)

;; Get feedback details
(define-read-only (get-feedback-entry (feedback-id uint))
  (map-get? feedback-entries { feedback-id: feedback-id })
)

;; Get evaluator collateral
(define-read-only (get-evaluator-deposit (evaluator principal))
  (map-get? evaluator-collateral { evaluator: evaluator })
)