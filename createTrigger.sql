/* Обновляет продолжительность курса */
CREATE FUNCTION updateCourseDuration()
    RETURNS TRIGGER
    AS $$
    DECLARE
        delta INTERVAL := 0;
        courseId INTEGER;
    BEGIN
        IF NEW IS NOT NULL THEN
            delta := delta + NEW.duration;
            courseId := NEW.courseId;
        END IF;

        IF OLD IS NOT NULL THEN
            delta := delta - OLD.duration;
            IF courseId IS NULL THEN
                courseId := OLD.courseId;
            END IF;
        END IF;
        
        IF courseId IS NOT NULL THEN
            UPDATE Courses 
            SET duration = duration + delta 
            WHERE id = courseId;
        END IF;

        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

/* Увеличить продолжительность курса при добавлении занятия */
CREATE TRIGGER IncreaseCourseDurationOnLessonInsertion
    AFTER INSERT ON Lessons
    FOR EACH ROW
    EXECUTE PROCEDURE updateCourseDuration();

/* Изменить продолжительность курса при обновлении занятия */
CREATE TRIGGER AdjustCourseDurationOnLessonUpdate
    AFTER UPDATE ON Lessons
    FOR EACH ROW
    EXECUTE PROCEDURE updateCourseDuration();

/* Уменьшить продолжительность курса при удалении занятия */
CREATE TRIGGER DecreaseCourseDurationOnLessonDeletion
    AFTER DELETE ON Lessons
    FOR EACH ROW
    EXECUTE PROCEDURE updateCourseDuration();