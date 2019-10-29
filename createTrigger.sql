CREATE FUNCTION updateCourseDuration()
    RETURNS TRIGGER
    AS $$
    BEGIN
        UPDATE Courses 
        SET duration = duration + NEW.duration 
        WHERE id = NEW.courseId;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateCourseDurationOnLessonInsertion
    AFTER INSERT ON Lessons
    FOR EACH ROW
    EXECUTE PROCEDURE updateCourseDuration();