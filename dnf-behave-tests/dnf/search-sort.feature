# @dnf5
# TODO(nsella) implement command search
Feature: Sort search command output

Background:
  Given I use repository "search-sort"

@bz1811802
Scenario: sort alphanumerically
  When I execute dnf with args "search name"
  Then the exit code is 0
   And stdout is
   """
   ========================== Name Exactly Matched: name ==========================
   name.src : Summary
   name.x86_64 : Summary
   ========================= Name & Summary Matched: name =========================
   name-summary.src : Summary of name
   name-summary.x86_64 : Summary of name
   name-summary-description.src : Summary of name
   name-summary-description.x86_64 : Summary of name
   name-summary-description-url.src : Summary of name
   name-summary-description-url.x86_64 : Summary of name
   name-summary-url.src : Summary of name
   name-summary-url.x86_64 : Summary of name
   ============================== Name Matched: name ==============================
   name-description.src : Summary
   name-description.x86_64 : Summary
   name-description-url.src : Summary
   name-description-url.x86_64 : Summary
   name-url.src : Summary
   name-url.x86_64 : Summary
   ============================ Summary Matched: name =============================
   summary.src : Summary of name
   summary.x86_64 : Summary of name
   summary-description.src : Summary of name
   summary-description.x86_64 : Summary of name
   summary-description-url.src : Summary of name
   summary-description-url.x86_64 : Summary of name
   summary-url.src : Summary of name
   summary-url.x86_64 : Summary of name
   """

@bz1811802
Scenario: sort --all alphanumerically
  When I execute dnf with args "search --all name"
  Then the exit code is 0
   And stdout is
   """
   ========================== Name Exactly Matched: name ==========================
   name.src : Summary
   name.x86_64 : Summary
   =============== Name & Summary & Description & URL Matched: name ===============
   name-summary-description-url.src : Summary of name
   name-summary-description-url.x86_64 : Summary of name
   ================== Name & Summary & Description Matched: name ==================
   name-summary-description.src : Summary of name
   name-summary-description.x86_64 : Summary of name
   ====================== Name & Summary & URL Matched: name ======================
   name-summary-url.src : Summary of name
   name-summary-url.x86_64 : Summary of name
   ========================= Name & Summary Matched: name =========================
   name-summary.src : Summary of name
   name-summary.x86_64 : Summary of name
   ==================== Name & Description & URL Matched: name ====================
   name-description-url.src : Summary
   name-description-url.x86_64 : Summary
   ======================= Name & Description Matched: name =======================
   name-description.src : Summary
   name-description.x86_64 : Summary
   =========================== Name & URL Matched: name ===========================
   name-url.src : Summary
   name-url.x86_64 : Summary
   ================== Summary & Description & URL Matched: name ===================
   summary-description-url.src : Summary of name
   summary-description-url.x86_64 : Summary of name
   ===================== Summary & Description Matched: name ======================
   summary-description.src : Summary of name
   summary-description.x86_64 : Summary of name
   ========================= Summary & URL Matched: name ==========================
   summary-url.src : Summary of name
   summary-url.x86_64 : Summary of name
   ============================ Summary Matched: name =============================
   summary.src : Summary of name
   summary.x86_64 : Summary of name
   ========================== Description Matched: name ===========================
   description.src : Summary
   description.x86_64 : Summary
   ============================== URL Matched: name ===============================
   url.src : Summary
   url.x86_64 : Summary
   """

