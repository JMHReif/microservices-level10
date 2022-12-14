//NOTE: This script loads subset of full data set (based on 10k books)
//Total loaded data size:
//92162 nodes
//84006 relationships

CREATE CONSTRAINT FOR (b:Book) REQUIRE b.book_id IS UNIQUE;
CREATE CONSTRAINT FOR (a:Author) REQUIRE a.author_id IS UNIQUE;
CREATE CONSTRAINT FOR (r:Review) REQUIRE r.review_id IS UNIQUE;

//Load 10,000 books
CALL apoc.load.json("https://data.neo4j.com/goodreads/goodreads_books_10k.json") YIELD value as book
MERGE (b:Book {book_id: book.book_id})
SET b += apoc.map.clean(book, ['authors'],[""]);
//10000 Book nodes

//Import initial authors for 10k books
CALL apoc.load.json("https://data.neo4j.com/goodreads/goodreads_books_10k.json") YIELD value as book
WITH book
UNWIND book.authors as author
MERGE (a:Author {author_id: author.author_id});
//12371 Author nodes

//Hydrate Author nodes
CALL apoc.periodic.iterate(
'CALL apoc.load.json("https://data.neo4j.com/goodreads/goodreads_book_authors.json.gz") YIELD value as author',
'WITH author MATCH (a:Author {author_id: author.author_id}) SET a += apoc.map.clean(author, [],[""])',
{batchsize: 10000}
);

//Load Author relationships
CALL apoc.load.json("https://data.neo4j.com/goodreads/goodreads_books_10k.json") YIELD value as book
WITH book
MATCH (b:Book {book_id: book.book_id})
WITH book, b
UNWIND book.authors as author
MATCH (a:Author {author_id: author.author_id})
MERGE (a)-[w:AUTHORED]->(b);
//14215 AUTHORED relationships

//Load Reviews
:auto CALL apoc.load.json("https://data.neo4j.com/goodreads/goodreads_reviews_dedup.json.gz") YIELD value as review
CALL { WITH review
 MATCH (b:Book) WHERE b.book_id = review.book_id
 WITH review, b
 MERGE (r:Review {review_id: review.review_id}) SET r += apoc.map.clean(review, [],[""])
 WITH b, r
 MERGE (b)<-[rel:WRITTEN_FOR]-(r)
} in transactions of 20000 rows;
//69791 Review nodes
//69791 WRITTEN_FOR relationships