-- AlterTable
ALTER TABLE "TrainingPreferences"
ADD COLUMN     "experience_level" TEXT NOT NULL DEFAULT 'iniciante',
ADD COLUMN     "equipment" TEXT NOT NULL DEFAULT 'academia_completa';
