---
name: adhoc-query
description: Turn an end user's ad hoc data request into a T-SQL query built from the examples in example-queries/.
argument-hint: <data request in the end user's words>
disable-model-invocation: true
---

# Ad hoc query

Build a query for this request: $ARGUMENTS

Every table, join, filter and column in the query needs **provenance**: a line in a file in `example-queries/` that uses it the same way. A part of the request without provenance is a **gap**. A gap ends the run with a coverage report; the query is built only from parts with provenance.

## Steps

1. **Request.** If the request above is empty, ask the user for it. Done when you hold the request text.

2. **Examples.** Read every `.sql` file in `example-queries/` in full. If the folder is missing or holds no `.sql` file, tell the user and stop. Done when every file is read.

3. **Parts.** Split the request into parts: the measures (what to count or show), the grain (per what), the filters (which rows) and the period. When a part has more than one reasonable reading, ask the user in one round: number each question and give your recommended answer. Done when every part has one meaning.

4. **Provenance.** For each part, find the example lines that give it its table, join, filter or column. Done when every part has an example file and line, or is marked as a gap.

5. **Gaps.** When any part is a gap, reply with the coverage report only: each covered part with its example file and line, and each gap with what is missing. The user adds an example query for the gap and runs the skill again.

6. **Query.** Write the query in T-SQL, in the style of the examples, with table names, joins and filters exactly as the examples write them. Select the minimal set of columns the request needs. When the request needs individual patients (a patient number, name or date of birth in the output), say so at the top of your reply.

7. **Reply.** Answer in the chat, in the user's language, with:
   - the query in a `sql` code block;
   - a provenance table: part, example file, line;
   - the meaning chosen for each part in step 3;
   - the line "Not executed: run this query yourself."

## Results

The user runs the query; Claude has no database connection (ASZ agreement). When the user wants Claude to check a result, Claude works from aggregated output that cannot point to a patient.
