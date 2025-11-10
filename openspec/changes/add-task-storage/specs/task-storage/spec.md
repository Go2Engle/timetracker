## ADDED Requirements

### Requirement: Task Data Model
The system SHALL define a Task data structure with the following attributes:
- id (integer, primary key)
- title (string, required, max 255 characters)
- description (string, optional)
- startTime (datetime, required)
- endTime (datetime, optional)
- elapsedSeconds (integer, default 0)
- status (enum: running, paused, stopped)
- categoryId (integer, optional, foreign key)
- createdAt (datetime, auto-generated)
- updatedAt (datetime, auto-generated)

#### Scenario: Task creation with minimal fields
- **WHEN** a task is created with only a title
- **THEN** the task SHALL have an auto-generated id, createdAt, and updatedAt timestamp
- **AND** the status SHALL default to "stopped"
- **AND** elapsedSeconds SHALL default to 0

#### Scenario: Task creation with all fields
- **WHEN** a task is created with title, description, category, and tags
- **THEN** all provided fields SHALL be stored correctly
- **AND** the task SHALL be retrievable with all associated metadata

### Requirement: Category Management
The system SHALL support task categorization through a Category data structure with:
- id (integer, primary key)
- name (string, required, unique, max 100 characters)
- color (string, hex color code)
- createdAt (datetime, auto-generated)

#### Scenario: Create unique category
- **WHEN** a category is created with a unique name
- **THEN** the category SHALL be stored successfully
- **AND** the category SHALL be available for task assignment

#### Scenario: Prevent duplicate categories
- **WHEN** a category is created with a name that already exists
- **THEN** the system SHALL reject the creation
- **AND** return an appropriate error

### Requirement: Tag Management
The system SHALL support task tagging through a Tag data structure with:
- id (integer, primary key)
- name (string, required, unique, max 50 characters)
- createdAt (datetime, auto-generated)

A task MAY have zero or more tags (many-to-many relationship).

#### Scenario: Add multiple tags to task
- **WHEN** a task is created or updated with multiple tags
- **THEN** all tag associations SHALL be stored correctly
- **AND** the task SHALL be retrievable with all associated tags

#### Scenario: Reuse existing tags
- **WHEN** a tag name already exists in the database
- **THEN** the existing tag SHALL be associated with the task
- **AND** no duplicate tag SHALL be created

### Requirement: Task Persistence
The system SHALL persist all task data locally using SQLite database with the following tables:
- tasks (main task data)
- categories (category definitions)
- tags (tag definitions)
- task_tags (junction table for task-tag relationships)

#### Scenario: Data survives app restart
- **WHEN** a task is created and the app is closed
- **AND** the app is reopened
- **THEN** the task SHALL still exist with all original data intact

#### Scenario: Database initialization
- **WHEN** the app is launched for the first time
- **THEN** the database and all required tables SHALL be created automatically
- **AND** the database SHALL be ready for task operations

### Requirement: Task CRUD Operations
The system SHALL provide the following operations through a repository interface:
- Create task
- Read task by ID
- Read all tasks
- Read tasks by date range
- Update task
- Delete task

#### Scenario: Create and retrieve task
- **WHEN** a task is created through the repository
- **THEN** the task SHALL be assigned a unique ID
- **AND** the task SHALL be retrievable by that ID
- **AND** all task fields SHALL match the created values

#### Scenario: Update task status
- **WHEN** a task's status is updated from "stopped" to "running"
- **THEN** the change SHALL be persisted to the database
- **AND** subsequent reads SHALL reflect the new status

#### Scenario: Delete task
- **WHEN** a task is deleted
- **THEN** the task SHALL no longer be retrievable
- **AND** all associated tag relationships SHALL be removed

#### Scenario: Query tasks by date range
- **WHEN** tasks are queried for a specific date range
- **THEN** only tasks with startTime within that range SHALL be returned
- **AND** tasks SHALL be ordered by startTime descending (newest first)

### Requirement: Data Type Safety
The system SHALL provide type-safe serialization and deserialization between Dart objects and database rows.

#### Scenario: Task to database mapping
- **WHEN** a Task object is converted to a database map
- **THEN** all fields SHALL be correctly mapped to their database column names
- **AND** datetime values SHALL be stored as ISO 8601 strings
- **AND** enum values SHALL be stored as strings

#### Scenario: Database to Task mapping
- **WHEN** a database row is converted to a Task object
- **THEN** all fields SHALL be correctly deserialized
- **AND** datetime strings SHALL be parsed to DateTime objects
- **AND** string status values SHALL be converted to TaskStatus enum

### Requirement: Database Migration Support
The system SHALL support database schema versioning and migrations.

#### Scenario: Initial database creation
- **WHEN** the database is created for the first time
- **THEN** the database version SHALL be set to 1
- **AND** all tables SHALL be created with the current schema

#### Scenario: Future schema updates
- **WHEN** the database version is incremented
- **THEN** the appropriate migration logic SHALL be executed
- **AND** existing data SHALL be preserved during migration
