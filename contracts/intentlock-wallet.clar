;; ============================================================
;; Contract: intentlock-wallet.clar
;; Purpose : Intent-based smart wallet core
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER        (err u11001))
(define-constant ERR-INTENT-NOT-FOUND (err u11002))
(define-constant ERR-INTENT-EXPIRED   (err u11003))
(define-constant ERR-ALREADY-USED     (err u11004))
(define-constant ERR-INVALID-AMOUNT   (err u11005))
(define-constant ERR-INVALID-EXPIRY   (err u11006))

;; -------------------------
;; DATA
;; -------------------------

(define-data-var owner principal tx-sender)
(define-data-var intent-counter uint u0)

;; intent-id => intent data
(define-map intents
  { id: uint }
  {
    recipient: principal,
    amount: uint,
    expires-at: uint,
    executed: bool
  }
)

;; -------------------------
;; OWNER CHECK
;; -------------------------

(define-read-only (is-owner)
  (is-eq tx-sender (var-get owner))
)

;; -------------------------
;; CREATE INTENT
;; -------------------------

(define-public (create-intent
  (recipient principal)
  (amount uint)
  (expires-at uint)
)
  (let ((id (+ (var-get intent-counter) u1)))
    (begin
      (asserts! (is-owner) ERR-NOT-OWNER)
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      (asserts! (> expires-at burn-block-height) ERR-INVALID-EXPIRY)

      (var-set intent-counter id)
      (map-set intents
        { id: id }
        {
          recipient: recipient,
          amount: amount,
          expires-at: expires-at,
          executed: false
        }
      )

      (ok id)
    )
  )
)

;; -------------------------
;; EXECUTE INTENT
;; -------------------------

(define-public (execute-intent (id uint))
  (let ((intent (map-get? intents { id: id })))
    (begin
      (asserts! (is-some intent) ERR-INTENT-NOT-FOUND)

      (let (
            (data (unwrap! intent ERR-INTENT-NOT-FOUND))
           )
        (begin
          (asserts!
            (<= burn-block-height (get expires-at data))
            ERR-INTENT-EXPIRED
          )

          (asserts!
            (not (get executed data))
            ERR-ALREADY-USED
          )

          ;; mark intent as executed
          (map-set intents
            { id: id }
            (merge data { executed: true })
          )

          ;; NOTE:
          ;; STX transfer should be handled by a vault contract
          ;; This wallet enforces intent correctness only

          (ok {
            to: (get recipient data),
            amount: (get amount data)
          })
        )
      )
    )
  )
)

;; -------------------------
;; READ-ONLY VIEWS
;; -------------------------

(define-read-only (get-intent (id uint))
  (map-get? intents { id: id })
)

(define-read-only (intent-valid? (id uint))
  (match (map-get? intents { id: id })
    intent
      (and
        (not (get executed intent))
        (<= burn-block-height (get expires-at intent))
      )
    false
  )
)
